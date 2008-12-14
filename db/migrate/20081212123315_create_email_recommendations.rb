class CreateEmailRecommendations < ActiveRecord::Migration
  def self.up
    create_table :email_recommendations do |t|
      t.integer :sender_id
      t.string :recipient_email_address
      t.integer :node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_recommendations
  end
end
