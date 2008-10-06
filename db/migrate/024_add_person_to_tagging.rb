class AddPersonToTagging < ActiveRecord::Migration
  def self.up
    add_column :tagged_models, :person_id, :integer, :null => true
  end

  def self.down
    remove_column :tagged_models, :person_id
  end
end
