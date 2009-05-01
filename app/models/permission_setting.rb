class PermissionSetting < ActiveRecord::Base
  ANYONE = 1
  OWNER = 2
  GROUP = 3

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :nodes
end
