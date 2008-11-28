class AddReferrerToLoggedAction < ActiveRecord::Migration
  def self.up
    add_column :logged_actions, :referrer, :text
    add_index :logged_actions, :referrer
  end

  def self.down
    remove_column :logged_actions, :referrer
  end
end
