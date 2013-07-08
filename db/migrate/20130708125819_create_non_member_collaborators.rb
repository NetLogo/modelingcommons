class CreateNonMemberCollaborators < ActiveRecord::Migration
  def change
    create_table :non_member_collaborators do |t|
      t.string :email
      t.string :name

      t.timestamps
    end

    add_index :non_member_collaborators, :email, :unique => true
    add_index :non_member_collaborators, :name
  end
end
