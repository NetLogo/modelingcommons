class AddAddingCollaboratorToNmc < ActiveRecord::Migration
  def change
    add_column :non_member_collaborations, :person_id, :integer, :null => false
  end
end
