class Person < ActiveRecord::Base
  has_many :node_versions
  has_many :nodes, :through => :node_versions

  has_many :postings
  has_many :logged_actions
  has_many :tags
  has_many :tagged_nodes
  has_many :recommendations
  has_many :email_recommendations
  has_many :spam_warnings

  has_many :memberships
  has_many :groups, :through => :memberships, :order => "lower(name) ASC"

  has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "40x40>" }, :default_url => "/images/default-person.png"

  attr_protected :avatar_file_name, :avatar_content_type, :avatar_size

  attr_accessor :password_confirmation

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_email :email_address, :level => 1
  validates_presence_of :password
  validates_uniqueness_of :email_address, :case_sensitive => false
  validates_confirmation_of :password

  def models
    self.nodes.select {|n| n.node_type_id == 1}.uniq
  end

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def administrated_groups
    self.groups.select {|g| g.is_administrator?(self) }
  end

  def spam_warning(model)
    self.spam_warnings.select { |sw| sw.node_id == model.id }.first || nil
  end

  def latest_action_time
    LoggedAction.maximum('logged_at', :conditions => ["person_id = ?", id])
  end

end
