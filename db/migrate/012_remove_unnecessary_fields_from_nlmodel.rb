class RemoveUnnecessaryFieldsFromNlmodel < ActiveRecord::Migration
  def self.up
    remove_column :nlmodels, :contents
    remove_column :nlmodels, :note

    rename_column :nlmodels, :person_id, :creator_id
  end

  def self.down
    rename_column :nlmodels, :creator_id, :person_id

    add_column :nlmodels, :contents, :text
    add_column :nlmodels, :note, :text
  end
end
