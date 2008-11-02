class NodeVersion < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  # acts_as_tsearch :vectors => {:fields => ["contents"], :locale => ''}
  # Doesn't work, because 'contents' is a bytea!  Can we change it to text?

  # NodeVersion.find_by_tsearch('who what where')

  SECTION_SEPARATOR = '@#$#@#$#@'

  def uploaded_body=(model_file)
    self.contents = model_file.read
  end

  def procedures_tab
    self.contents.split(SECTION_SEPARATOR)[0]
  end

  def gui_tab
    self.contents.split(SECTION_SEPARATOR)[1]
  end

  def info_tab

    self.contents.split(SECTION_SEPARATOR)[2]
  end

end
