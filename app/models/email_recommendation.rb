# Model that represents a recommendation for a model that a user has sent

class EmailRecommendation < ActiveRecord::Base
  belongs_to :person
  belongs_to :node
end
