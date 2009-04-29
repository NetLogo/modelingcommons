class NodeVersion < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  acts_as_ferret :fields => ['file_contents']

  SECTION_SEPARATOR = '@#$#@#$#@'

  def uploaded_body=(model_file)
    self.file_contents = model_file.read
  end

  def procedures_tab
    self.file_contents.split(SECTION_SEPARATOR)[0]
  end

  def gui_tab
    self.file_contents.split(SECTION_SEPARATOR)[1]
  end

  def info_tab

    self.file_contents.split(SECTION_SEPARATOR)[2]
  end

end
