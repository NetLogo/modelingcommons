class ChangeSessionToTextFromString < ActiveRecord::Migration
  def self.up
    change_column :sessions, :session_id, :text
  end

  def self.down
  end
end
