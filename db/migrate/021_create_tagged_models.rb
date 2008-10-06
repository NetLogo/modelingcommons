class CreateTaggedModels < ActiveRecord::Migration
  def self.up
    create_table :tagged_models do |t|
      t.integer :nlmodel_id
      t.integer :tag_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tagged_models
  end
end
