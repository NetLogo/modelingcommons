require 'test_helper'

class LoggedActionTest < ActiveSupport::TestCase
  should_belong_to :person
  should_belong_to :node
end
