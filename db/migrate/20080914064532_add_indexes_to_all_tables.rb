class AddIndexesToAllTables < ActiveRecord::Migration
  def self.up
    # News_Items table
    add_index :news_items, :title
    add_index :news_items, :person_id
    add_index :news_items, :created_at

    # Nodes table
    add_index :nodes, :node_type_id
    add_index :nodes, :parent_id
    add_index :nodes, :name
    add_index :nodes, :created_at
    add_index :nodes, :visibility_id
    add_index :nodes, :changeability_id

    # Permission settings

    add_index :permission_settings, :name

    # Tagged_nodes
    add_index :tagged_nodes, :created_at
    add_index :tagged_nodes, :node_id
    add_index :tagged_nodes, :person_id
    add_index :tagged_nodes, :tag_id
    add_index :tagged_nodes, :updated_at

    # Tags
    add_index :tags, :name
    add_index :tags, :person_id
    add_index :tags, :created_at
    add_index :tags, :updated_at
  end

  def self.down
    # News_Items table
    remove_index :news_items, :title
    remove_index :news_items, :person_id
    remove_index :news_items, :created_at

    # Nodes table
    remove_index :nodes, :node_type_id
    remove_index :nodes, :parent_id
    remove_index :nodes, :name
    remove_index :nodes, :created_at
    remove_index :nodes, :visibility_id
    remove_index :nodes, :changeability_id

    # Permission settings
    remove_index :permission_settings, :name

    # Tagged_nodes
    remove_index :tagged_nodes, :created_at
    remove_index :tagged_nodes, :node_id
    remove_index :tagged_nodes, :person_id
    remove_index :tagged_nodes, :tag_id
    remove_index :tagged_nodes, :updated_at

    # Tags
    remove_index :tags, :name
    remove_index :tags, :person_id
    remove_index :tags, :created_at
    remove_index :tags, :updated_at
  end
end
