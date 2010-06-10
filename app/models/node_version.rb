# Model for storing versions of nodes

class NodeVersion < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :node_id
  validates_presence_of :person_id

  after_save :update_model_modification_time

  delegate :is_model?, :to => :node

  # acts_as_tsearch :fields => ["file_contents"]

  SECTION_SEPARATOR = '@#$#@#$#@'

  def uploaded_body=(model_file)
    self.file_contents = model_file.read
  end

  def procedures_tab
    is_model? ? file_contents.split(SECTION_SEPARATOR)[0] : ""
  end

  def info_tab
    is_model? ? file_contents.split(SECTION_SEPARATOR)[2] : ""
  end

  def netlogo_version
    if is_model?
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

  def procedures_content
    file_contents.split(SECTION_SEPARATOR)[0]
  end

  def info_content
    file_contents.split(SECTION_SEPARATOR)[2]
  end

end
