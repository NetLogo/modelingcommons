require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_uniqueness_of :name
         
  should_have_many :memberships
  should_have_many :people, :through => :memberships
         
  should_have_many :nodes
end
