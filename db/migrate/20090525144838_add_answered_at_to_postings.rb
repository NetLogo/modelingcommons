class AddAnsweredAtToPostings < ActiveRecord::Migration
  def self.up
    add_column :postings, :answered_at, :timestamp
  end

  def self.down
    remove_column :postings, :answered_at
  end
end
