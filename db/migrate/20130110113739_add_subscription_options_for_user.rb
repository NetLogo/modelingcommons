class AddSubscriptionOptionsForUser < ActiveRecord::Migration
  def self.up
    add_column :people, :send_site_updates, :boolean, :default => true
    add_column :people, :send_model_updates, :boolean, :default => true
    add_column :people, :send_tag_updates, :boolean, :default => true
  end

  def self.down
    remove_column :people, :send_site_updates
    remove_column :people, :send_model_updates
    remove_column :people, :send_tag_updates
  end
end
