# Model to keep track of discussion postings

class Posting < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :title, :body, :node_id

  scope :questions, :conditions => { :is_question => true }, :order => "created_at DESC"
  scope :unanswered_questions, :conditions => { :is_question => true, :answered_at => nil }, :order => "created_at DESC"

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  after_save :notify_people

  def was_answered?
    !!self.answered_at
  end

  def first_posting?
    node.postings.count == 1
  end

  def new_thing
    {:id => id,
      :node_id => node_id,
      :node_name => node.name,
      :date => created_at,
      :description => "Posting by '#{person.fullname}' about the '#{node.name}' model",
      :title => title,
      :contents => body}
  end

  def notify_people
    Notifications.updated_discussion(node, person).deliver
  end

end
