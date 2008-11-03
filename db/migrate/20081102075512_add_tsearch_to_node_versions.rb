class AddTsearchToNodeVersions < ActiveRecord::Migration
  def self.up
    add_column :node_versions, :vectors, :tsvector
  end

  def self.down
    remove_column :node_versions, :vectors
  end
end
