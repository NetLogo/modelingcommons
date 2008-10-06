class AddForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    rename_column :nodes, :visibility, :visibility_id
    rename_column :nodes, :changeability, :changeability_id

    execute "ALTER TABLE node_versions ADD CONSTRAINT node_versions_node_fkey FOREIGN KEY (node_id) REFERENCES Nodes (id);"
    execute "ALTER TABLE node_versions ADD CONSTRAINT node_versions_person_fkey FOREIGN KEY (person_id) REFERENCES People (id);"

    # Nodes table
    execute "ALTER TABLE nodes ADD CONSTRAINT node_type_fkey FOREIGN KEY (node_type_id) REFERENCES Node_types (id);"
    execute "ALTER TABLE nodes ADD CONSTRAINT node_parent_fkey FOREIGN KEY (parent_id) REFERENCES Nodes (id);"
    execute "ALTER TABLE nodes ADD CONSTRAINT node_visibility_fkey FOREIGN KEY (visibility_id) REFERENCES Permission_Settings (id);"
    execute "ALTER TABLE nodes ADD CONSTRAINT node_changeability_fkey FOREIGN KEY (changeability_id) REFERENCES Permission_Settings (id);"

    # Postings table
    execute "ALTER TABLE postings ADD CONSTRAINT posting_versions_person_fkey FOREIGN KEY (person_id) REFERENCES People (id);"
    execute "ALTER TABLE postings ADD CONSTRAINT posting_node_fkey FOREIGN KEY (node_id) REFERENCES Nodes (id);"
    execute "ALTER TABLE postings ADD CONSTRAINT posting_parent_fkey FOREIGN KEY (parent_id) REFERENCES Nodes (id);"

    # Tags
    execute "ALTER TABLE tagged_nodes ADD CONSTRAINT tag_node_fkey FOREIGN KEY (node_id) REFERENCES Nodes (id);"
    execute "ALTER TABLE tagged_nodes ADD CONSTRAINT tag_tag_fkey FOREIGN KEY (tag_id) REFERENCES Tags (id);"
    execute "ALTER TABLE tagged_nodes ADD CONSTRAINT tag_person_fkey FOREIGN KEY (person_id) REFERENCES People (id);"

    execute "ALTER TABLE tags ADD CONSTRAINT tag_creator_person_fkey FOREIGN KEY (person_id) REFERENCES People (id);"


  end

  def self.down
    execute "ALTER TABLE node_versions DROP CONSTRAINT node_versions_node_fkey;"
    execute "ALTER TABLE node_versions DROP CONSTRAINT node_versions_person_fkey;"

    # Nodes
    execute "ALTER TABLE nodes DROP CONSTRAINT node_type_fkey;"
    execute "ALTER TABLE nodes DROP CONSTRAINT node_parent_fkey;"
    execute "ALTER TABLE nodes DROP CONSTRAINT node_visibility_fkey;"
    execute "ALTER TABLE nodes DROP CONSTRAINT node_changeability_fkey;"

    # Postings
    execute "ALTER TABLE postings DROP CONSTRAINT posting_versions_person_fkey;"
    execute "ALTER TABLE postings DROP CONSTRAINT posting_node_fkey;"
    execute "ALTER TABLE postings DROP CONSTRAINT posting_parent_fkey;"

    # Tags
    execute "ALTER TABLE tagged_nodes DROP CONSTRAINT posting_versions_person_fkey;"
    execute "ALTER TABLE tagged_nodes DROP CONSTRAINT posting_node_fkey;"
    execute "ALTER TABLE tagged_nodes DROP CONSTRAINT posting_parent_fkey;"

    execute "ALTER TABLE tags DROP CONSTRAINT tag_creator_person_fkey;"

    rename_column :nodes, :visibility_id, :visibility
    rename_column :nodes, :changeability_id, :changeability
  end
end
