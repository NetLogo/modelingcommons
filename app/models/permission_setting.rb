class PermissionSetting < ActiveRecord::Base
  ANYONE = 1
  OWNER = 2
  GROUP = 3

  validates_presence_of :name, :short_form

  has_many :nodes
end
