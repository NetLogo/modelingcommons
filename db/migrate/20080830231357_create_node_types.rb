class CreateNodeTypes < ActiveRecord::Migration
  def self.up
    create_table :node_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :node_types, :name, :unique => true

    NodeType.create(:name => 'NetLogo Model', :description => "NetLogo model")
    NodeType.create(:name => 'Model preview', :description => "PNG preview file")
    NodeType.create(:name => 'Curriculum document', :description => "Word or PDF file")
    NodeType.create(:name => 'Background image', :description => "Background images required for a model to run")
    NodeType.create(:name => 'Input data', :description => "Data that a file needs")

  end

  def self.down
    drop_table :node_types
  end
end
