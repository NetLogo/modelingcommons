class AddFieldsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :person_id, :integer
    add_column :projects, :group_id, :integer
    add_column :projects, :visibility_id, :integer
    add_column :projects, :changeability_id, :integer

    add_index :projects, :person_id
    add_index :projects, :group_id
    add_index :projects, :visibility_id
    add_index :projects, :changeability_id
  end

  def self.down
    remove_column :projects, :person_id
    remove_column :projects, :group_id
    remove_column :projects, :visibility_id
    remove_column :projects, :changeability_id
  end
end
