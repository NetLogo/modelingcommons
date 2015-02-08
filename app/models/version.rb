class NetlogoModelFileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.split(Version::SECTION_SEPARATOR).length < 8
      record.errors[attribute] << 'Not a legal NetLogo model'
    end
  end
end

class Version < ActiveRecord::Base
  attr_accessible :node_id, :person_id, :contents, :description

  belongs_to :person
  belongs_to :node

  validates :person_id, :presence => true
  validates :node_id, :presence => true
  validates :description, :presence => true
  validates :contents,:presence => true

  validates :contents, :netlogo_model_file => true

  default_scope :order => 'created_at DESC'

  SECTION_SEPARATOR = '@#$#@#$#@'

  scope :info_keyword_matches, lambda { |term| { :conditions => ["split_part(contents, ?, 3) ilike ?", SECTION_SEPARATOR, '%' + term + '%'] } }
  scope :procedures_keyword_matches, lambda { |term| { :conditions => ["split_part(contents, ?, 1) ilike ?", SECTION_SEPARATOR, '%' + term + '%'] } }


  after_save :update_node_modification_time
  after_save :notify_authors
  after_save :update_collaborators
  after_save :tweet_version

  def update_node_modification_time
    if node
      node.update_attributes(:updated_at => Time.now)
    else
      STDERR.puts "Version is looking for node_id '#{node_id}', but it does not exist"
    end
  end

  def notify_authors
    if node.nil?
      STDERR.puts "Version is looking for node_d '#{node_id}', but it does not exist"
    else
      return unless node.versions.count > 1 
      return if node.people.uniq.count == 1 and node.people.first == person

      Notifications.modified_model(node, person).deliver
    end
  end

  def update_collaborators
    if person.nil?
      STDERR.puts "Looking for person '#{person_id}', but cannot find it"
    elsif node.nil?
      STDERR.puts "Looking for node '#{node_id}', but cannot find it"
    else

      author_collaboration_id = CollaboratorType.find_by_name("Author").id
      c = 
        Collaboration.find_or_create_by_node_id_and_person_id_and_collaborator_type_id(node.id,
                                                                                       person.id,
                                                                                       author_collaboration_id)
    end
  end

  def procedures_tab
    @procedures_tab ||= contents.split(SECTION_SEPARATOR)[0]
  end

  def info_tab
    @info_tab ||= contents.split(SECTION_SEPARATOR)[2]
  end

  def netlogo_version
    @netlogo_version ||= contents.split(SECTION_SEPARATOR)[4].gsub("\n", "").gsub("NetLogo ", "")
  end

  def new_thing
    {:id => id,
      :node_id => node_id,
      :node_name => node.name,
      :date => created_at,
      :description => "New version of '#{node.name}' uploaded by '#{person.fullname}'",
      :title => "Update to model '#{node.name}'",
      :contents => description}
  end

  def self.text_search(query)
    Version.find_by_sql ["SELECT * FROM Versions WHERE (to_tsvector('english', contents)) @@ to_tsquery('english', ?)", query.gsub(/\s+/, ' | ')]
  end

  def tweet_version
    return unless node.world_visible?
    if node.versions.count == 1
      Twitter.update("#{person.fullname} added #NetLogo model '#{node.name}' at #{node.url}, our #{ActiveSupport::Inflector::ordinalize(Node.count)} model!")
    else
      Twitter.update("#{person.fullname} added version #{node.versions.count} of #NetLogo model '#{node.name}': #{node.url}")
    end
  end

end
