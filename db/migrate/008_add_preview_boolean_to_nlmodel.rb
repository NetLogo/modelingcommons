class AddPreviewBooleanToNlmodel < ActiveRecord::Migration
  def self.up
    add_column :nlmodels, :has_preview, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :nlmodels, :has_preview
  end
end
