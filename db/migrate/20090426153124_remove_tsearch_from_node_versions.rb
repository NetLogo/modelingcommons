class RemoveTsearchFromNodeVersions < ActiveRecord::Migration
  def self.up
    remove_column :node_versions, :vectors
  end

  def self.down
    add_column :node_versions, :vectors, :tsvector
  end
end
