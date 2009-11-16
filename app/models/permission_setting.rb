class PermissionSetting < ActiveRecord::Base
  ANYONE = 1
  OWNER = 2
  GROUP = 3

  validates_presence_of :name, :short_form

  has_many :nodes

  def is_owner?
    id == PermissionSetting::OWNER
  end

  def is_group?
    id == PermissionSetting::GROUP
  end

  def is_anyone?
    id == PermissionSetting::ANYONE
  end

end
