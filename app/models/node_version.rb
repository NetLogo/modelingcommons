# Model for storing versions of nodes.

# Note that this version (currently only in the "mongo" branch) uses
# MongoDB and MongoMapper, rather than ActiveRecord.

class NodeVersion
  include MongoMapper::Document

  key :node_id, Integer, :index => true
  key :person_id, Integer, :index => true
  key :description, String, :index => true
  key :contents, String

  key :info_keyword_index, Array
  key :procedures_keyword_index, Array

  timestamps!

  validates_presence_of :node_id
  validates_presence_of :person_id
  validates_presence_of :description
  validates_presence_of :contents

  before_save :update_indexes
  after_save :update_node_modification_time

  SECTION_SEPARATOR = '@#$#@#$#@'

  def node
    node_id.nil? ? nil : Node.find(node_id)
  end

  def person
    person_id.nil? ? nil : Person.find(person_id)
  end

  def person=(a_person)
    person_id = a_person.id
    save!
  end

  def uploaded_body=(model_file)
    contents = model_file.read
  end

  def procedures_tab
    contents.split(SECTION_SEPARATOR)[0]
  end

  def info_tab
    contents.split(SECTION_SEPARATOR)[2]
  end

  def netlogo_version
    contents.split(SECTION_SEPARATOR)[4].gsub("\n", "").gsub("NetLogo ", "")
  end

  def procedures_content
    contents.split(SECTION_SEPARATOR)[0]
  end

  def info_content
    contents.split(SECTION_SEPARATOR)[2]
  end

  # Callbacks
  def update_indexes
    self.info_keyword_index = info_tab.downcase.split.select {|word| word =~ /^\w[-\w.]+$/ }.uniq
    self.procedures_keyword_index = procedures_tab.downcase.split.select {|word| word =~ /^\w[-\w.]+$/ }.uniq
  end

  def update_node_modification_time
    node.update_attributes(:updated_at => Time.now)
  end

end
