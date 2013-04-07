# Class to handle attachments to models

class NodeAttachment
  include MongoMapper::Document

  key :node_id, Integer, :index => true
  key :person_id, Integer,  :index => true
  key :description, String,  :index => true
  key :filename, String,  :index => true
  key :type, String,  :index => true
  key :contents, Binary
  timestamps!
  ensure_index :created_at
  ensure_index :updated_at 


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

  validates_presence_of :node_id
  validates_presence_of :person_id
  validates_presence_of :description
  validates_presence_of :filename
  validates_presence_of :type
  validates_presence_of :contents

  validate :type_must_be_defined

  def type_must_be_defined
    errors.add_to_base "The type of this document is undefined" unless TYPES.member?(type)
  end

  def person
    Person.find(person_id)
  end

end
