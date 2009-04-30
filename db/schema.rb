# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090430091507) do

  create_table "email_recommendations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email_address"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logged_actions", :force => true do |t|
    t.integer  "person_id"
    t.datetime "logged_at"
    t.text     "message"
    t.string   "ip_address"
    t.string   "browser_info"
    t.string   "url"
    t.text     "params",       :null => false
    t.text     "session"
    t.text     "cookies"
    t.text     "flash"
    t.text     "referrer"
    t.integer  "node_id"
    t.string   "controller"
    t.string   "action"
  end

  add_index "logged_actions", ["ip_address"], :name => "index_logged_actions_on_ip_address"
  add_index "logged_actions", ["node_id"], :name => "index_logged_actions_on_node_id"
  add_index "logged_actions", ["person_id"], :name => "index_logged_actions_on_person_id"
  add_index "logged_actions", ["referrer"], :name => "index_logged_actions_on_referrer"
  add_index "logged_actions", ["url"], :name => "index_logged_actions_on_url"

  create_table "memberships", :force => true do |t|
    t.integer  "person_id"
    t.integer  "group_id"
    t.boolean  "is_administrator", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status",           :default => "pending", :null => false
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["person_id", "group_id"], :name => "index_memberships_on_person_id_and_group_id", :unique => true

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_items", ["created_at"], :name => "index_news_items_on_created_at"
  add_index "news_items", ["person_id"], :name => "index_news_items_on_person_id"
  add_index "news_items", ["title"], :name => "index_news_items_on_title"

  create_table "node_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
    t.string   "mime_type"
  end

  add_index "node_types", ["name"], :name => "index_node_types_on_name", :unique => true

  create_table "node_versions", :force => true do |t|
    t.integer  "node_id",       :null => false
    t.integer  "person_id"
    t.text     "old_contents"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "file_contents"
  end

  create_table "nodes", :force => true do |t|
    t.integer  "node_type_id",                    :null => false
    t.integer  "parent_id"
    t.text     "name",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visibility_id",    :default => 1, :null => false
    t.integer  "changeability_id", :default => 1, :null => false
    t.integer  "group_id"
  end

  add_index "nodes", ["changeability_id"], :name => "index_nodes_on_changeability_id"
  add_index "nodes", ["created_at"], :name => "index_nodes_on_created_at"
  add_index "nodes", ["group_id"], :name => "index_nodes_on_group_id"
  add_index "nodes", ["name"], :name => "index_nodes_on_name"
  add_index "nodes", ["node_type_id"], :name => "index_nodes_on_node_type_id"
  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["visibility_id"], :name => "index_nodes_on_visibility_id"

  create_table "people", :force => true do |t|
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.boolean  "administrator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "people", ["email_address"], :name => "index_people_on_email_address"
  add_index "people", ["first_name"], :name => "index_people_on_first_name"
  add_index "people", ["last_name"], :name => "index_people_on_last_name"

  create_table "permission_settings", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_form"
  end

  add_index "permission_settings", ["name"], :name => "index_permission_settings_on_name"

  create_table "pg_ts_cfg", :id => false, :force => true do |t|
    t.text "ts_name",  :null => false
    t.text "prs_name", :null => false
    t.text "locale"
  end

  create_table "pg_ts_cfgmap", :id => false, :force => true do |t|
    t.text   "ts_name",                  :null => false
    t.text   "tok_alias",                :null => false
    t.string "dict_name", :limit => nil
  end

  create_table "pg_ts_dict", :id => false, :force => true do |t|
    t.text   "dict_name",                      :null => false
    t.string "dict_init",       :limit => nil
    t.text   "dict_initoption"
    t.string "dict_lexize",     :limit => nil, :null => false
    t.text   "dict_comment"
  end

  create_table "pg_ts_parser", :id => false, :force => true do |t|
    t.text   "prs_name",                     :null => false
    t.string "prs_start",     :limit => nil, :null => false
    t.string "prs_nexttoken", :limit => nil, :null => false
    t.string "prs_end",       :limit => nil, :null => false
    t.string "prs_headline",  :limit => nil, :null => false
    t.string "prs_lextype",   :limit => nil, :null => false
    t.text   "prs_comment"
  end

  create_table "postings", :force => true do |t|
    t.integer  "person_id"
    t.integer  "node_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "is_question", :default => false, :null => false
    t.datetime "deleted_at"
  end

  add_index "postings", ["body"], :name => "index_postings_on_body"
  add_index "postings", ["created_at"], :name => "index_postings_on_created_at"
  add_index "postings", ["node_id"], :name => "index_postings_on_nlmodel_id"
  add_index "postings", ["parent_id"], :name => "index_postings_on_parent_id"
  add_index "postings", ["person_id"], :name => "index_postings_on_person_id"
  add_index "postings", ["title"], :name => "index_postings_on_title"
  add_index "postings", ["updated_at"], :name => "index_postings_on_updated_at"

  create_table "recommendations", :force => true do |t|
    t.integer  "node_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "spam_warnings", :force => true do |t|
    t.integer  "person_id"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tagged_nodes", :force => true do |t|
    t.integer  "node_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.text     "comment"
  end

  add_index "tagged_nodes", ["created_at"], :name => "index_tagged_nodes_on_created_at"
  add_index "tagged_nodes", ["node_id"], :name => "index_tagged_nodes_on_node_id"
  add_index "tagged_nodes", ["person_id"], :name => "index_tagged_nodes_on_person_id"
  add_index "tagged_nodes", ["tag_id"], :name => "index_tagged_nodes_on_tag_id"
  add_index "tagged_nodes", ["updated_at"], :name => "index_tagged_nodes_on_updated_at"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["created_at"], :name => "index_tags_on_created_at"
  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["person_id"], :name => "index_tags_on_person_id"
  add_index "tags", ["updated_at"], :name => "index_tags_on_updated_at"

  create_table "test_tsquery", :id => false, :force => true do |t|
    t.text "txtkeyword"
    t.text "txtsample"
  end

end
