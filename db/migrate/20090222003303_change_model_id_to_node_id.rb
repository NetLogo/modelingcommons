class ChangeModelIdToNodeId < ActiveRecord::Migration
  def self.up
    rename_column :spam_warnings, :model_id, :node_id
  end

  def self.down
    rename_column :spam_warnings, :node_id, :model_id
  end
end
