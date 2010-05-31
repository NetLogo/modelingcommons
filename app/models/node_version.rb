# Model for storing versions of nodes

class NodeVersion < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :node_id
  validates_presence_of :person_id

  after_save :update_model_modification_time

  # acts_as_tsearch :fields => ["file_contents"]

  SECTION_SEPARATOR = '@#$#@#$#@'

  def uploaded_body=(model_file)
    self.file_contents = model_file.read
  end

  def procedures_tab
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      self.file_contents.split(SECTION_SEPARATOR)[0]
    else
      ""
    end
  end

  def info_tab
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      self.file_contents.split(SECTION_SEPARATOR)[2]
    else
      ""
    end
  end

  def model_shapes
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      self.file_contents.split(SECTION_SEPARATOR)[3]
    else
      ""
    end
  end

  def netlogo_version
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      if self.file_contents.index(SECTION_SEPARATOR).nil?
        ""
      else
        self.file_contents.split(SECTION_SEPARATOR)[4].gsub("\n", "").gsub("NetLogo ", "")
      end
    else
      ""
    end
  end

  def update_model_modification_time
    node.update_attributes(:updated_at => Time.now)
  end

end
