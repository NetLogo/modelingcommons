class RemoveNlmodel < ActiveRecord::Migration
  def self.up
    drop_table :nlmodel_versions
    drop_table :nlmodel_documents
    drop_table :nlmodels
  end

  def self.down
    create_table "nlmodels", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "person_id",  :null => false
    end

    create_table "nlmodel_documents", :force => true do |t|
      t.string   "title"
      t.integer  "person_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "nlmodel_id", :null => false
      t.text     "filename",   :null => false
      t.binary   "content"
    end

    create_table "nlmodel_versions", :force => true do |t|
      t.integer  "nlmodel_id"
      t.integer  "person_id"
      t.text     "contents"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "note"
    end
  end
end
