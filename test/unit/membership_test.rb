require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  should_validate_presence_of :person
  should_validate_presence_of :group

  should_belong_to :person
  should_belong_to :group
end
