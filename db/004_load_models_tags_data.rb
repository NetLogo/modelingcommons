require 'active_record/fixtures'

class LoadModelsTagsData < ActiveRecord::Migration
  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "dev_data")
#    Fixtures.create_fixtures(directory, "models_tags")
  end

  def self.down
    drop_table :models_tags
    create_table(:models_tags, :id => false) do |t|
      t.column :model_id, :integer
      t.column :tag_id,   :integer
    end
  end
end
