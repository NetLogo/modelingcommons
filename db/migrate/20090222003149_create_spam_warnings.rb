class CreateSpamWarnings < ActiveRecord::Migration
  def self.up
    create_table :spam_warnings do |t|
      t.integer :person_id
      t.integer :model_id

      t.timestamps
    end
  end

  def self.down
    drop_table :spam_warnings
  end
end
