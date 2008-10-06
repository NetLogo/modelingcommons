class ChangeLogColumnTypes < ActiveRecord::Migration
  def self.up
    change_column :logged_actions, :params, :text, :null => false
  end

  def self.down
    change_column :logged_actions, :params, :string, :null => false
  end
end
