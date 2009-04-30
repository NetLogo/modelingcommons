class AddDeletedAtToPostings < ActiveRecord::Migration
  def self.up
    add_column :postings, :deleted_at, :timestamp
  end

  def self.down
    remove_column :postings, :deleted_at
  end
end
