class MakePersonIdNonNull < ActiveRecord::Migration
  def self.up
    change_column :nlmodels, :person_id, :integer, :null => false
  end

  def self.down
    change_column :nlmodels, :person_id, :integer, :null => true
  end
end
