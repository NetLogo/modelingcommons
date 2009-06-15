require 'test_helper'

class NodeTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_presence_of :node_type_id
  should_validate_presence_of :visibility_id
  should_validate_presence_of :changeability_id

  should_validate_numericality_of :node_type_id
  should_validate_numericality_of :visibility_id
  should_validate_numericality_of :changeability_id

end
