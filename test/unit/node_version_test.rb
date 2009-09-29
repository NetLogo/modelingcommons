require 'test_helper'

class NodeVersionTest < ActiveSupport::TestCase
  should_belong_to :node
  should_belong_to :person

  should_validate_presence_of :node_id
  should_validate_presence_of :person_id
end
