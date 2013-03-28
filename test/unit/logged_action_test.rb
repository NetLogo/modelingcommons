require 'test_helper'

class LoggedActionTest < ActiveSupport::TestCase
  should belong_to :person
  should belong_to :node
end
