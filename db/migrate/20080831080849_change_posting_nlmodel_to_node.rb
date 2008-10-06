class ChangePostingNlmodelToNode < ActiveRecord::Migration
  def self.up
    rename_column :postings, :nlmodel_id, :node_id
  end

  def self.down
    rename_column :postings, :node_id, :nlmodel_id
  end
end
