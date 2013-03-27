class CreateCollaborations < ActiveRecord::Migration
  def self.up
    create_table :collaborations do |t|
      t.integer :person_id
      t.integer :node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :collaborations
  end
end
