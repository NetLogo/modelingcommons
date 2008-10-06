class AddAdminFlagToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :administrator, :boolean
  end

  def self.down
    remove_column :people, :administrator
  end
end
