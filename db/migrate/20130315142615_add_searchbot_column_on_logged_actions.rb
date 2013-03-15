class AddSearchbotColumnOnLoggedActions < ActiveRecord::Migration
  def self.up
    add_column :logged_actions, :is_searchbot, :boolean, :default => false
  end

  def self.down
    remove_column :logged_actions, :is_searchbot
  end
end
