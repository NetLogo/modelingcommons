class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :node_id, :null => false
      t.integer :person_id, :null => false
      t.string :description, :null => false
      t.binary :contents, :null => false
      t.string :filename, :null => false
      t.string :type, :null => false

      t.timestamps
    end

    add_index :attachments, :node_id
    add_index :attachments, :person_id
    add_index :attachments, :type
  end

  def self.down
    drop_table :attachments
  end
end
