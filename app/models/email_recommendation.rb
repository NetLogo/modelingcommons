class EmailRecommendation < ActiveRecord::Base
  belongs_to :person
  belongs_to :node

  validates_uniqueness_of :node, :scoped_to => :person_id

end
