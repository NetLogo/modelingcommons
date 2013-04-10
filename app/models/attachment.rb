class Attachment < ActiveRecord::Base

  belongs_to :node
  belongs_to :person

  validates :node_id, :presence => true
  validates :person_id, :presence => true
  validates :description, :presence => true
  validates :filename, :presence => true
  validates :content_type, :presence => true
  validates :contents, :presence => true

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
    errors.add_to_base "The type of this document is undefined" unless TYPES.member?(content_type)
  end

end
