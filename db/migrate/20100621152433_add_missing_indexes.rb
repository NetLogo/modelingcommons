class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :email_recommendations, :person_id
    add_index :email_recommendations, :node_id
    add_index :memberships, :person_id
    add_index :node_projects, :project_id
    add_index :node_projects, :node_id
    add_index :recommendations, :node_id
    add_index :recommendations, :person_id
    add_index :spam_warnings, :person_id
    add_index :spam_warnings, :node_id
  end

  def self.down
  end
end
