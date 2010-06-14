class RemoveNodeVersionsTable < ActiveRecord::Migration
  def self.up
    drop_table :node_versions
  end

  def self.down
  end
end
