class ChangeCreatorBack < ActiveRecord::Migration
  def self.up
    rename_column :nlmodels, :creator_id, :person_id
  end

  def self.down
    rename_column :nlmodels, :person_id, :creator_id
  end
end
