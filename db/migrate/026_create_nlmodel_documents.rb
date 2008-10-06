class CreateNlmodelDocuments < ActiveRecord::Migration
  def self.up
    create_table :nlmodel_documents do |t|
      t.string :title
      t.text :content
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :nlmodel_documents
  end
end
