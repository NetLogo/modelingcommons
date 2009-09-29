require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_uniqueness_of :name

  should_have_many :memberships
  should_have_many :people, :through => :memberships

  should_have_many :nodes
end
