class ChangeNodeVersionContentToBytea < ActiveRecord::Migration
  def self.up
    # Turn "contents" into "old_contents"
    rename_column :node_versions, :contents, :old_contents

    # Now add a new "contents" which is binary
    add_column :node_versions, :contents, :bytea
  end

  def self.down
    # Now add a new "contents" which is binary
    remove_column :node_versions, :contents

    # Turn "contents" into "old_contents"
    rename_column :node_versions, :old_contents, :contents
  end
end
