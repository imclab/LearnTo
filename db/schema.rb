# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120120053400) do

  create_table "class_rooms", :force => true do |t|
    t.string   "name"
    t.integer  "creator_id"
    t.integer  "occupancy"
    t.decimal  "price"
    t.integer  "description_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.text     "summary"
    t.string   "tag_line"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "documents", :force => true do |t|
    t.integer  "resource_id"
    t.string   "title"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "content"
    t.boolean  "dirty"
    t.text     "parsed_content"
  end

  add_index "documents", ["resource_id"], :name => "index_documents_on_resource_id"

  create_table "forums", :force => true do |t|
    t.integer  "class_room_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "forum_id"
    t.text     "content"
    t.string   "title"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "last_updated"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ratings", ["comment_id"], :name => "index_ratings_on_comment_id"
  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "resource_pages", :force => true do |t|
    t.string   "section"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "class_room_id"
  end

  add_index "resource_pages", ["class_room_id"], :name => "index_resource_pages_on_class_room_id"

  create_table "resources", :force => true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "name"
    t.string   "caption"
    t.string   "url"
    t.string   "type"
    t.integer  "user_id"
    t.integer  "class_room_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_type"
    t.integer  "document_id"
    t.string   "source_call"
    t.boolean  "hidden"
    t.integer  "order"
    t.integer  "section_id"
  end

  add_index "resources", ["class_room_id"], :name => "index_resources_on_class_room_id"
  add_index "resources", ["document_id"], :name => "index_resources_on_document_id"
  add_index "resources", ["section_id"], :name => "index_resources_on_section_id"
  add_index "resources", ["user_id"], :name => "index_resources_on_user_id"

  create_table "sections", :force => true do |t|
    t.integer  "order"
    t.string   "title"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "resource_page_id"
  end

  add_index "sections", ["resource_page_id"], :name => "index_sections_on_resource_page_id"

  create_table "subcomments", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "comment_id"
  end

  add_index "subcomments", ["user_id"], :name => "index_subcomments_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "class_room_id"
    t.string   "permission_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "user_permissions", ["class_room_id"], :name => "index_user_permissions_on_class_room_id"
  add_index "user_permissions", ["user_id"], :name => "index_user_permissions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                                 :null => false
    t.string   "email",                                 :null => false
    t.string   "crypted_password",                      :null => false
    t.string   "password_salt",                         :null => false
    t.string   "persistence_token",                     :null => false
    t.integer  "login_count",        :default => 0,     :null => false
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "active",             :default => false, :null => false
    t.string   "perishable_token",   :default => "",    :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true

end
