class RenameTaggedModelToTaggedNode < ActiveRecord::Migration
  def self.up
    rename_table :tagged_models, :tagged_nodes
  end

  def self.down
    rename_table :tagged_nodes, :tagged_models
  end
end
