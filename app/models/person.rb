# Class to model people (users) of the system

class Person < ActiveRecord::Base
  SALT_SECRET = 'NetLogo is a really cool modeling environment!'

  has_many :postings
  has_many :logged_actions
  has_many :tags
  has_many :tagged_nodes
  has_many :recommendations
  has_many :email_recommendations
  has_many :spam_warnings
  has_many :projects

  has_many :versions
  has_many :attachments

  has_many :collaborations
  has_many :nodes, :through => :collaborations

  has_many :memberships
  has_many :groups, :through => :memberships, :order => "lower(name) ASC"

  has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "40x40>" }, :default_url => "/images/default-person/:style/default-person.png"

  attr_protected :avatar_file_name, :avatar_content_type, :avatar_size

  attr_accessor :password_confirmation

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_presence_of :registration_consent, :message => "must be checked"
  validates_email :email_address, :level => 1
  validates_presence_of :password
  validates_uniqueness_of :email_address, :case_sensitive => false
  validates_confirmation_of :password

  named_scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}
  named_scope :phone_book, :order => "last_name, first_name"

  after_validation_on_create :generate_salt_and_encrypt_password
  after_validation_on_update :encrypt_updated_password

  def node_versions
    versions
  end

  def models
    nodes
  end

  def fullname
    @fullname ||= "#{first_name} #{last_name}"
  end

  def phonebook_name
    @phonebook_name ||= "#{last_name}, #{first_name} (#{email_address})"
  end

  def administrated_groups
    groups.select {|group| group.is_administrator?(self) }
  end

  def self.search(term)
    all(:conditions => [ "position( ? in lower(first_name || ' ' || last_name) ) > 0 ", term])
  end

  def spam_warning(model)
    spam_warnings.select { |sw| sw.node_id == model.id }.first || nil
  end

  def latest_action_time
    LoggedAction.maximum('logged_at', :conditions => ["person_id = ?", id])
  end

  def Person.search(term)
    all(:conditions => [ "position( ? in lower(first_name || last_name) ) > 0 ", term])
  end

  def Person.generate_salt(timestamp)
    Digest::SHA1.hexdigest("#{SALT_SECRET}--#{timestamp}")
  end

  def Person.encrypted_password(the_salt, plaintext)
    Digest::SHA1.hexdigest("#{the_salt}--#{plaintext}")
  end

  def download_name
    fullname.gsub(/[\s\/]/, '_')
  end

  def zipfile_name
    "#{download_name}.zip"
  end

  def zipfile_name_full_path
    "#{RAILS_ROOT}/public/modelzips/#{zipfile_name}"
  end

  def create_zipfile(web_user)
    Zippy.create zipfile_name_full_path do |io|

      zipped_nodes = [ ]

      nodes.each do |node|
        next unless node.visible_to_user?(web_user)

        zipped_nodes << node
        io["#{download_name}/#{node.download_name}/#{download_name}.nlogo"] = node.contents.to_s

        node.attachments.each do |attachment|
          io["#{download_name}/#{node.download_name}/#{attachment.filename}"] = attachment.contents.to_s
        end

      end

      manifest_string = "Models written by #{fullname}\n"

      if zipped_nodes.empty?
        manifest_string << "No models available for download."
      else
        zipped_nodes.each_with_index do |node, index|
          manifest_string << "[%3d]\t" % index
          manifest_string << "Created #{node.created_at}\t"
          manifest_string << "Last updated #{node.updated_at}\t"
          manifest_string << "#{node.id}\t"
          manifest_string << "#{node.name}\t"
          manifest_string << "http://modelingcommons.org/browse/one_model/#{node.id}\n"
        end
      end

      io["MANIFEST"] = manifest_string

    end

    zipfile_name_full_path
  end

  def downloaded_nodes
    LoggedAction.find(:all, :conditions => {:action => 'download_model', :person_id => id}, :include => :node).map { |la| Node.find(la.node_id) }.uniq
  end

  def questions
    postings.select { |p| p.is_question? }
  end

  def non_questions
    postings.reject { |p| p.is_question? }
  end

  def viewed_nodes
    LoggedAction.find(:all, :conditions => { :action => 'one_model', :person_id => id}, :include => :node).map { |la| Node.first(:conditions => {:id => la.node_id})}.uniq
  end

  def user_model_downloads
    user_downloads = LoggedAction.find(:all, :conditions => { :controller => 'account', :action => 'download', :person_id => id}).map { |la| [la.logged_at, YAML.load(la.params)['id']]  }
    
    downloaded_nodes = [ ]

    user_downloads.each do |download_event|
      Person.find(download_event[1]).nodes.each do |node|
        next if node.created_at > download_event[0]
        downloaded_nodes << node
      end
    end
    downloaded_nodes.uniq
  end

  def project_model_downloads
    project_downloads = LoggedAction.find(:all, :conditions => { :controller => 'project', :action => 'download', :person_id => id}).map { |la| [la.logged_at, YAML.load(la.params)['id']]  }
    
    downloaded_nodes = [ ]

    project_downloads.each do |download_event|
      Project.find(download_event[1]).nodes.each do |node|
        next if node.created_at > download_event[0]
        downloaded_nodes << node
      end
    end
    downloaded_nodes.uniq
  end

  def tag_model_downloads
    tag_downloads = LoggedAction.find(:all, :conditions => { :controller => 'tags', :action => 'download', :person_id => id}).map { |la| [la.logged_at, YAML.load(la.params)['id']]  }
    
    downloaded_nodes = [ ]

    tag_downloads.each do |download_event|
      Tag.find(download_event[1]).nodes.each do |node|
        next if node.created_at > download_event[0]
        downloaded_nodes << node
      end
    end
    downloaded_nodes.uniq
  end

  private

  def generate_salt_and_encrypt_password
    return unless new_record? 

    timestamp = created_at || Time.now
    self.salt = Person.generate_salt(timestamp)
    self.password = Person.encrypted_password(salt, password)
  end

  def encrypt_updated_password
    self.password = Person.encrypted_password(salt, password)
  end

end
