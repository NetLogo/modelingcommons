class RemoveNodeTypeIdTableAndReference < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :node_type_id
    drop_table :node_types
  end

  def self.down
  end
end
