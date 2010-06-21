# Model to keep track of discussion postings

class Posting < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :title, :body

  named_scope :questions, :conditions => { :is_question => true }, :order => "created_at DESC"
  named_scope :unanswered_questions, :conditions => { :is_question => true, :answered_at => nil }, :order => "created_at DESC"

  def was_answered?
    !!self.answered_at
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

end
