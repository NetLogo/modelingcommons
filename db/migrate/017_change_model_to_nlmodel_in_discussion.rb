class ChangeModelToNlmodelInDiscussion < ActiveRecord::Migration
  def self.up
    rename_column :postings, :model_id, :nlmodel_id
  end

  def self.down
    rename_column :postings, :nlmodel_id, :model_id
  end
end
