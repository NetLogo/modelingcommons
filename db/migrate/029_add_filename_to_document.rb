class AddFilenameToDocument < ActiveRecord::Migration
  def self.up
    add_column :nlmodel_documents, :filename, :text, :null => false
  end

  def self.down
    remove_column :nlmodel_documents, :filename
  end
end
