class CreatePostings < ActiveRecord::Migration
  def self.up
    create_table :postings do |t|
      t.integer :person_id
      t.integer :model_id
      t.string :title
      t.text :body
      t.timestamp :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :postings
  end
end
