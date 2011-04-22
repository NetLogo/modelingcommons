class AddDemographicsFields < ActiveRecord::Migration
  def self.up
    add_column :people, :sex, :string
    add_column :people, :birthdate, :date
    add_column :people, :country_name, :string
  end

  def self.down
    remove_column :people, :sex
    remove_column :people, :birthdate
    remove_column :people, :country_name
  end
end
