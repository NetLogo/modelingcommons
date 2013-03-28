require 'test_helper'

class EmailRecommendationTest < ActiveSupport::TestCase
  should belong_to :person
  should belong_to :node
end
