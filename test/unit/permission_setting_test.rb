require 'test_helper'

class PermissionSettingTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_uniqueness_of :name

end
