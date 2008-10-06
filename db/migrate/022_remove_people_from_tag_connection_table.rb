class RemovePeopleFromTagConnectionTable < ActiveRecord::Migration
  def self.up
    remove_column :tagged_models, :person_id
  end

  def self.down
    add_column :tagged_models, :person_id, :integer, :null => true
  end
end
