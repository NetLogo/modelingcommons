class AddParentToPosting < ActiveRecord::Migration
  def self.up
    add_column :postings, :parent_id, :integer, :null => true
  end

  def self.down
    remove_column :postings, :parent_id
  end
end
