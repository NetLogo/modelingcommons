class CreateNodeVersions < ActiveRecord::Migration
  def self.up
    create_table :node_versions do |t|
      t.integer :node_id
      t.integer :person_id
      t.text :contents
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :node_versions
  end
end
