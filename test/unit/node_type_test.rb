require 'test_helper'

class NodeTypeTest < ActiveSupport::TestCase
  should_have_many :nodes
  should_validate_presence_of :name
  should_validate_presence_of :description
  should_validate_uniqueness_of :name
end
