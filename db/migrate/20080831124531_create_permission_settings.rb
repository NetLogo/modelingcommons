class CreatePermissionSettings < ActiveRecord::Migration
  def self.up
    create_table :permission_settings do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_settings
  end
end
