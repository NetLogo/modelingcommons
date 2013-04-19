# Model to keep track of recommended models

class Recommendation < ActiveRecord::Base
  attr_accessible :node_id, :person_id
  
  belongs_to :person
  belongs_to :node

  validates :person_id, :presence => true, :uniqueness => {  :scope => :node_id }
end
