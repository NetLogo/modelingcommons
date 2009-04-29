class RenameContentsToFileContents < ActiveRecord::Migration
  def self.up
    rename_column :node_versions, :contents, :file_contents
  end

  def self.down
    rename_column :node_versions, :file_contents, :contents
  end
end
