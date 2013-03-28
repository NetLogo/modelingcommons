require 'test_helper'

class PermissionSettingTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_uniqueness_of :name
         
  should validate_presence_of :short_form
  should validate_uniqueness_of :short_form
end
