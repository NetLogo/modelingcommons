class CreateNlmodelVersions < ActiveRecord::Migration
  def self.up
    create_table :nlmodel_versions do |t|
      t.integer :nlmodel_id
      t.integer :person_id
      t.text :contents
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :nlmodel_versions
  end
end
