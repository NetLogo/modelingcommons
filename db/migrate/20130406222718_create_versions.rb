class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer :node_id, :null => false
      t.integer :person_id, :null => false
      t.text :description, :null => false
      t.text :contents, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
