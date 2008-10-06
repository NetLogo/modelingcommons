class CreatePermissionSettings < ActiveRecord::Migration
  def self.up
    create_table :permission_settings do |t|
      t.string :name, :null => false
      t.timestamps
    end

    PermissionSetting.create(:name => 'Everyone')
    PermissionSetting.create(:name => 'No one but yourself')
    PermissionSetting.create(:name => 'Members of your group')
  end

  def self.down
    drop_table :permission_settings
  end
end
