class AddAvatarFileNameToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :avatar_file_name, :text
  end

  def self.down
    remove_column :people, :avatar_file_name
  end
end
