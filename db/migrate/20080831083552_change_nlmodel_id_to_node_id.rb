class ChangeNlmodelIdToNodeId < ActiveRecord::Migration
  def self.up
    rename_column :tagged_models, :nlmodel_id, :node_id
  end

  def self.down
    rename_column :tagged_models, :node_id, :nlmodel_id
  end
end
