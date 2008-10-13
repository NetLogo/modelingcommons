class AddIndexesToGroups < ActiveRecord::Migration
  def self.up
    # Memberships
    add_index :memberships, :person_id
    add_index :memberships, :group_id

    # Node groups
    add_index :nodes, :group_id
  end

  def self.down
    remove_index :memberships, :person_id
    remove_index :memberships, :group_id

    remove_index :nodes, :group_id
  end
end
