class AddNicknameToPermissions < ActiveRecord::Migration
  def self.up
    add_column :permission_settings, :short_form, :string
  end

  def self.down
    remove_column :permission_settings, :short_form
  end
end
