class AddCollaboratorTypeToCollaborators < ActiveRecord::Migration
  def self.up
    add_column :collaborations, :collaborator_type_id, :integer
  end

  def self.down
    remove_column :collaborations, :collaborator_type_id
  end
end
