class ChangePreviewToBeInDb < ActiveRecord::Migration
  def self.up
    remove_column :nlmodels, :has_preview
    add_column :nlmodels, :preview_image, :binary
  end

  def self.down
    add_column :nlmodels, :has_preview, :default => false
    remove_column :nlmodels, :preview_image
  end
end
