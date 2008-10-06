class MovePreviewBackToFilesystem < ActiveRecord::Migration
  def self.up
    remove_column :nlmodels, :preview_image
  end

  def self.down
    add_column :nlmodels, :preview_image, :binary
  end
end
