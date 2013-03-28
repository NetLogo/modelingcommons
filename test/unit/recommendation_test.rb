require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase
  should belong_to :person
  should belong_to :node
         
end
