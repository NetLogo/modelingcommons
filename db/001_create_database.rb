class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.column :name,        :string, :null => false
      t.column :path,        :string, :null => false
      t.column :information, :text, :null => false
      t.column :source,      :text, :null => false
#      t.column :image_url,   :string, :null => false
    end
    
    create_table :tags do |t|
      t.column :name, :string, :null => false
    end
    
    create_table(:models_tags, :id => false) do |t|
      t.column :model_id, :integer
      t.column :tag_id,   :integer
    end
    
  end

  def self.down
    drop_table :models_tags
    drop_table :tags
    drop_table :models
  end
end
