# Model to keep track of tag-node joins

class TaggedNode < ActiveRecord::Base
  attr_accessible :comment, :node_id, :tag_id, :person_id

  belongs_to :node
  belongs_to :tag
  belongs_to :person

  validates :node_id, :presence => true
  validates :tag_id, :presence => true
  validates :person_id, :presence => true

  validates :tag_id, :uniqueness => { :scope => [:node_id, :person_id] }

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  after_save :notify_people
  after_save :tweet_tagged_node

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

  def notify_people
    notification_recipients = (node.people + tag.people).uniq
    logger.warn "Notification recipients for tagged node '#{self.inspect}' = '#{notification_recipients}'"
    Notifications.applied_tag(notification_recipients, tag, node).deliver
  end

  def tweet_tagged_node
    return unless node.world_visible?
    Twitter.update("#{person.name} tagged '#{node.name}', (#{node.url}), with '#{tag.name}' (#{tag.url}).")
  end

end
