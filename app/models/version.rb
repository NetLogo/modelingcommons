class Version < ActiveRecord::Base

  belongs_to :person
  belongs_to :node

  validates_presence_of :person_id
  validates_presence_of :node_id
  validates_presence_of :description
  validates_presence_of :contents

  SECTION_SEPARATOR = '@#$#@#$#@'
  validate :must_be_valid_netlogo_file
  def must_be_valid_netlogo_file
    if contents.split(SECTION_SEPARATOR).length < 8
      errors.add_to_base "Does not appear to be a valid NetLogo file"
    end
  end

  scope :info_keyword_matches,  lambda { |term| where(:info_keyword_index => term) }
  scope :procedures_keyword_matches,  lambda { |term| where(:procedures_keyword_index => term) }

  after_save :update_node_modification_time
  after_save :notify_authors
  after_save :update_collaborators

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
      return unless node.node_versions.count > 1 
      return if node.people.uniq.count == 1 and node.people.first == person

      # Notifications.deliver_modified_model(node, person) 
    end
  end

  def update_collaborators
    author_collaboration_id = CollaboratorType.find_by_name("Author").id
    c = 
      Collaboration.find_or_create_by_node_id_and_person_id_and_collaborator_type_id(node.id,
                                                                                     person.id,
                                                                                     author_collaboration_id)
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

end
