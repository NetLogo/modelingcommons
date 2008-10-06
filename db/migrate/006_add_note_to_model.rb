class AddNoteToModel < ActiveRecord::Migration
  def self.up
    add_column :nlmodels, :person_id, :integer
    add_column :nlmodels, :note, :text
  end

  def self.down
    remove_column :nlmodels, :note
    remove_column :nlmodels, :person_id
  end
end
