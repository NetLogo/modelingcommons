# Model to keep track of recommended models

class Recommendation < ActiveRecord::Base
  belongs_to :person
  belongs_to :node

  validates :node_id, :presence => true, :uniqueness => true, :scope => :person_id
  validates :person_id, :presence => true, :uniqueness => true, :scope => :person_id
end
