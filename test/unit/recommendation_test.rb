require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase
  should_belong_to :person
  should_belong_to :node

  should_validate_uniqueness_of :node_id, :scoped_to => :person_id
end
