class CreateCollaboratorTypes < ActiveRecord::Migration
  def self.up
    create_table :collaborator_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :collaborator_types
  end
end
