class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.integer :node_type_id
      t.integer :parent_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
