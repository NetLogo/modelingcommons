class CreateNodeProjects < ActiveRecord::Migration
  def self.up
    create_table :node_projects do |t|

      t.integer :project_id
      t.integer :node_id
      t.timestamps
    end
  end

  def self.down
    drop_table :node_projects
  end
end
