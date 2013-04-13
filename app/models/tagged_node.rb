# Model to keep track of tag-node joins

class TaggedNode < ActiveRecord::Base
  attr_accessible :comment

  belongs_to :node
  belongs_to :tag
  belongs_to :person

  validates :node_id, :presence => true
  validates :tag_id, :presence => true
  validates :person_id, :presence => true

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  def new_thing
    {:id => id,
      :node_id => node_id,
      :node_name => node.name,
      :date => created_at,
      :description => "Model '#{node.name}' tagged with '#{tag.name}' by '#{person.fullname}'",
      :title => "Model '#{node.name}' tagged with '#{tag.name}' by '#{person.fullname}'",
      :contents => "<p>'#{person.fullname} tagged the '#{node.name}' model</p>"
    }
  end

end
