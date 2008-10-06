class AddNoteToVersion < ActiveRecord::Migration
  def self.up
    add_column :nlmodel_versions, :note, :text
  end

  def self.down
    remove_column :nlmodel_versions, :note
  end
end
