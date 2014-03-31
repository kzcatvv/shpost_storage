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

ActiveRecord::Schema.define(version: 20140328071000) do

  create_table "commodities", force: true do |t|
    t.string   "cno"
    t.string   "name"
    t.integer  "goodstype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  create_table "goodstypes", force: true do |t|
    t.string   "gtno"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "storage_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["user_id", "storage_id", "role"], name: "index_roles_on_user_id_and_storage_id_and_role", unique: true

  create_table "specifications", force: true do |t|
    t.integer  "commodity_id"
    t.string   "model"
    t.string   "size"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.string   "operation",          default: "", null: false
    t.string   "status"
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.string   "object_symbol"
    t.integer  "amount",             default: 0,  null: false
    t.datetime "checked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "storages", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  create_table "suppliers", force: true do |t|
    t.string   "sno"
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",       default: 0,  null: false
    t.string   "operation",     default: "", null: false
    t.string   "object_class"
    t.integer  "object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_symbol"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               default: "", null: false
    t.string   "role",                   default: "", null: false
    t.string   "name"
    t.integer  "unit_id"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
