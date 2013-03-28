require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  should validate_presence_of :person
  should validate_presence_of :group

  should belong_to :person
  should belong_to :group
end
