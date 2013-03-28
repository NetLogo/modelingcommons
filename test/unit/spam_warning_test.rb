require 'test_helper'

class SpamWarningTest < ActiveSupport::TestCase
  should belong_to :person
  should belong_to :node
end
