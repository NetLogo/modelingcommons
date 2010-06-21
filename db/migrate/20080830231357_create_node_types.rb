class CreateNodeTypes < ActiveRecord::Migration
  def self.up
    create_table :node_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :node_types, :name, :unique => true

  end

  def self.down
    drop_table :node_types
  end
end
