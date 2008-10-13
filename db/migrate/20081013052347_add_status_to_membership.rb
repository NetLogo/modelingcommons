class AddStatusToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :status, :string, :null => false, :default => 'pending'
  end

  def self.down
    remove_column :memberships, :status
  end
end
