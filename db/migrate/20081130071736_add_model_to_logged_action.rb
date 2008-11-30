class AddModelToLoggedAction < ActiveRecord::Migration
  def self.up
    add_column :logged_actions, :node_id, :integer
    add_index :logged_actions, :node_id
  end

  def self.down
    remove_column :logged_actions, :node_id
  end
end
