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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150505164536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customer_users", force: true do |t|
    t.integer "customer_id"
    t.integer "user_id"
  end

  create_table "customers", force: true do |t|
    t.string   "customer_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_mappings", force: true do |t|
    t.integer "device_id"
    t.integer "site_id"
    t.integer "user_id"
    t.integer "customer_id"
    t.boolean "enable",      default: true, null: false
  end

  add_index "device_mappings", ["device_id", "site_id", "user_id", "customer_id"], name: "unique_device_mapping", unique: true, using: :btree

  create_table "device_properties", force: true do |t|
    t.integer  "device_mapping_id"
    t.integer  "property_id"
    t.string   "value",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.string   "name",       null: false
    t.string   "hw_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", force: true do |t|
    t.string   "key",        null: false
    t.string   "metric"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "sessions", id: false, force: true do |t|
    t.string   "token",       null: false
    t.integer  "user_id"
    t.integer  "site_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_configs", force: true do |t|
    t.string   "name",                      null: false
    t.string   "value",                     null: false
    t.string   "job_id",     default: ""
    t.integer  "site_id",                   null: false
    t.boolean  "enabled",    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_users", force: true do |t|
    t.integer "site_id"
    t.integer "user_id"
  end

  add_index "site_users", ["site_id", "user_id"], name: "index_site_users_on_site_id_and_user_id", unique: true, using: :btree

  create_table "sites", force: true do |t|
    t.string   "name"
    t.boolean  "deleted",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["name"], name: "index_sites_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
