class IndexVersions < ActiveRecord::Migration
  def self.up
    add_index :versions, :person_id
    add_index :versions, :node_id
  end

  def self.down
  end
end
