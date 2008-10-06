class Posting < ActiveRecord::Base
  belongs_to :node
  belongs_to :person

  validates_presence_of :title, :body
end
