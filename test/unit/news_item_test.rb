require 'test_helper'

class NewsItemTest < ActiveSupport::TestCase
  should_belong_to :person
  should_validate_presence_of :person
end
