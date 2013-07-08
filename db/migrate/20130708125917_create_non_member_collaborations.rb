class CreateNonMemberCollaborations < ActiveRecord::Migration
  def change
    create_table :non_member_collaborations do |t|
      t.integer :non_member_collaborator_id
      t.integer :node_id
      t.integer :collaborator_type_id

      t.timestamps
    end

    add_index :non_member_collaborations, :non_member_collaborator_id
    add_index :non_member_collaborations, :node_id
    add_index :non_member_collaborations, :collaborator_type_id
  end
end
