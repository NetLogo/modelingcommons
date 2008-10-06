class AddConstraintsToNodes < ActiveRecord::Migration
  def self.up
    change_column :nodes, :node_type_id, :integer, :null => false
    change_column :nodes, :name, :text, :null => false

    change_column :node_versions, :node_id, :integer, :null => false
  end

  def self.down
    change_column :node_versions, :node_id, :integer, :null => true
    change_column :nodes, :name, :text, :null => true

    change_column :nodes, :node_type_id, :integer, :null => true
  end
end
