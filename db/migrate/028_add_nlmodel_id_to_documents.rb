class AddNlmodelIdToDocuments < ActiveRecord::Migration
  def self.up
    add_column :nlmodel_documents, :nlmodel_id, :integer, :null => false
  end

  def self.down
    remove_column :nlmodel_documents, :nlmodel_id
  end
end
