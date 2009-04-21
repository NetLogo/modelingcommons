class AddMimeTypeToNodeType < ActiveRecord::Migration
  def self.up
      add_column :node_types, :mime_type, :string
  end

  def self.down
      remove_column :node_types, :mime_type
  end
end
