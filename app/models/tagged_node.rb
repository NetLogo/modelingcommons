# Model to keep track of tag-node joins

class TaggedNode < ActiveRecord::Base
  belongs_to :node
  belongs_to :tag
  belongs_to :person

  validates_presence_of :node_id, :tag_id, :person_id
end
