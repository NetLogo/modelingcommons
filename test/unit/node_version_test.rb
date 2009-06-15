require 'test_helper'

class NodeVersionTest < ActiveSupport::TestCase
  should_belong_to :node
  should_belong_to :person
end
