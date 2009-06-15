require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase
  should_validate_uniqueness_of :node_id, :scoped_to => :person_id
end
