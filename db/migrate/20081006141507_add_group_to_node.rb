class AddGroupToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :group_id, :integer, :null => true
  end

  def self.down
    remove_column :nodes, :group_id
  end
end
