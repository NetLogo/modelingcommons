# Model to keep track of recommended models

class Recommendation < ActiveRecord::Base
  belongs_to :person
  belongs_to :node

  validates_uniqueness_of :node_id, :scope => :person_id
end
