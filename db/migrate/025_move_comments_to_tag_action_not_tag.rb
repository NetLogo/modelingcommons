class MoveCommentsToTagActionNotTag < ActiveRecord::Migration
  def self.up
    remove_column :tags, :comment
    add_column :tagged_models, :comment, :text, :null => true
  end

  def self.down
    add_column :tags, :comment, :text, :null => true
    remove_column :tagged_models, :comment
  end
end
