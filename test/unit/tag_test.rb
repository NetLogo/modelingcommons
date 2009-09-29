require 'test_helper'

class TagTest < ActiveSupport::TestCase
  should_belong_to :person
  should_have_many :tagged_nodes
  should_have_many :nodes

  should_validate_presence_of :name
  should_validate_presence_of :person_id

  should_validate_uniqueness_of :name, :case_sensitive => false
end
