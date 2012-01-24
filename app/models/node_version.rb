# Model for storing versions of nodes.

class NodeVersion
  include MongoMapper::Document

  key :node_id, Integer, :index => true
  key :person_id, Integer, :index => true
  key :description, String, :index => true
  key :contents, String

  key :info_keyword_index, Array, :index => true
  key :procedures_keyword_index, Array, :index => true

  timestamps!
  ensure_index :created_at
  ensure_index :updated_at 

  validates_presence_of :node_id
  validates_presence_of :person_id
  validates_presence_of :description
  validates_presence_of :contents

  before_save :update_indexes
  after_save :update_node_modification_time

  scope :info_keyword_matches,  lambda { |term| where(:info_keyword_index => term) }
  scope :procedures_keyword_matches,  lambda { |term| where(:procedures_keyword_index => term) }

  SECTION_SEPARATOR = '@#$#@#$#@'
  validate :must_be_valid_netlogo_file
  def must_be_valid_netlogo_file
    if contents.split(SECTION_SEPARATOR).length < 8
      errors.add_to_base "Does not appear to be a valid NetLogo file"
    end
  end

  def node
    @node ||= (node_id.nil? ? nil : Node.find(node_id, :include => [:visibility, :changeability, :tags, :group]))
  end

  def person
    @person ||= (person_id.nil? ? nil : Person.find(person_id))
  end

  def person=(a_person)
    person_id = a_person.id
    save!
  end

  def uploaded_body=(model_file)
    contents = model_file.read
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

  # Callbacks
  def update_indexes
    self.info_keyword_index = info_tab.downcase.split.select {|word| word =~ /^\w[-\w.]+$/ }.uniq if info_tab
    self.procedures_keyword_index = procedures_tab.downcase.split.select {|word| word =~ /^\w[-\w.]+$/ }.uniq if procedures_tab
  end

  def update_node_modification_time
    node.update_attributes(:updated_at => Time.now)
  end

end
