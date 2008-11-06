class ChangePeopleModifiedAtToUpdatedAt < ActiveRecord::Migration
  def self.up
    rename_column :people, :modified_at, :updated_at
  end

  def self.down
    rename_column :people, :updated_at, :modified_at
  end
end
