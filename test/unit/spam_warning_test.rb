require 'test_helper'

class SpamWarningTest < ActiveSupport::TestCase
  should_belong_to :person
  should_belong_to :node
end
