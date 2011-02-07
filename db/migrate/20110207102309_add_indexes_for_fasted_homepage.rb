class AddIndexesForFastedHomepage < ActiveRecord::Migration
  def self.up
    add_index :logged_actions, :controller
    add_index :logged_actions, :action
  end

  def self.down
  end
end
