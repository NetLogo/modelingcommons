class Posting < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :title, :body

  def was_answered?
    !!self.answered_at
  end

end
