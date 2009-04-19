class AddControllerAndActionToLoggedActions < ActiveRecord::Migration
  def self.up
    add_column :logged_actions, :controller, :string
    add_column :logged_actions, :action, :string
  end

  def self.down
    remove_column :logged_actions, :controller
    remove_column :logged_actions, :action
  end
end
