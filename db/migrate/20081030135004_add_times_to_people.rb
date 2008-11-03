class AddTimesToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :created_at, :timestamp
    add_column :people, :modified_at, :timestamp
  end

  def self.down
    remove_column :people, :created_at
    remove_column :people, :modified_at
  end
end
