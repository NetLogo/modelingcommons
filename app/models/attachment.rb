class Attachment < ActiveRecord::Base

  belongs_to :node
  belongs_to :person

  validates_presence_of :node_id
  validates_presence_of :person_id
  validates_presence_of :description
  validates_presence_of :filename
  validates_presence_of :content_type
  validates_presence_of :contents

  validate :type_must_be_defined

  TYPES = {
    'background' => 'image/png',
    'data' => 'application/x-binary',
    'extension' => 'application/x-binary',
    'gif' => 'image/gif',
    'html' => 'text/html',
    'jpeg' => 'image/jpeg',
    'pdf' => 'application/pdf',
    'png' => 'image/png',
    'powerpoint' => 'application/vnd.ms-powerpoint',
    'preview' => 'image/png',
    'word' => 'application/msword'
  }

  def type_must_be_defined
    STDERR.puts "[Attachment#type_must_be_defined] TYPES = '#{TYPES.inspect}'"
    STDERR.puts "[Attachment#type_must_be_defined] content_type = '#{content_type.inspect}'"
    STDERR.puts "[Attachment#type_must_be_defined] TYPES.member?(content_type) = '#{TYPES.member?(content_type)}'"

    errors.add_to_base "The type of this document is undefined" unless TYPES.member?(content_type)
  end

end
