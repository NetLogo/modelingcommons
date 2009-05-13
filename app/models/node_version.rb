class NodeVersion < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  acts_as_ferret :fields => ['file_contents']

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

  def gui_tab
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      self.file_contents.split(SECTION_SEPARATOR)[1]
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

  def model_version
    if self.node.node_type_id == Node::MODEL_NODE_TYPE
      self.file_contents.split(SECTION_SEPARATOR)[4]
    else
      ""
    end
  end

end
