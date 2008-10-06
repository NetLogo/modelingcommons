class AddShortNameToNodeType < ActiveRecord::Migration
  def self.up
    add_column :node_types, :short_name, :string
  end

  def self.down
    remove_column :node_types, :short_name
  end
end
