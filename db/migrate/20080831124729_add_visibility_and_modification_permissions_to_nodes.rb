class AddVisibilityAndModificationPermissionsToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :visibility, :integer, :null => false, :default => 1
    add_column :nodes, :changeability, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :nodes, :changeability
    remove_column :nodes, :visibility
  end
end
