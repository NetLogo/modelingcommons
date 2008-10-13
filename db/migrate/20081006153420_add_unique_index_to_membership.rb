class AddUniqueIndexToMembership < ActiveRecord::Migration
  def self.up
    remove_index :memberships, :person_id
    add_index :memberships, [:person_id, :group_id], :unique => true
  end

  def self.down
    remove_index :memberships, [:person_id, :group_id]
    add_index :memberships, :person_id
  end
end
