class AddWantsHelpToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :wants_help, :boolean, :null => false, :default => false
    add_index :nodes, :wants_help
  end
end
