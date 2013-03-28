require 'test_helper'

class TagTest < ActiveSupport::TestCase
  should belong_to :person
  should have_many :tagged_nodes
  should have_many :nodes
         
  should validate_presence_of :name
  should validate_presence_of :person_id
         
end
