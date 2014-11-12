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

ActiveRecord::Schema.define(version: 20141111080042) do

  create_table "areas", force: true do |t|
    t.integer  "storage_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "area_code",  default: "",   null: false
    t.string   "name",       default: "",   null: false
    t.string   "is_bad",     default: "no"
  end

  create_table "bcm_interfaces", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "businesses", force: true do |t|
    t.string   "name",       default: "", null: false
    t.string   "email"
    t.string   "contactor"
    t.string   "phone"
    t.string   "address"
    t.string   "desc"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "no"
    t.string   "secret_key"
    t.integer  "alertday",   default: 0
    t.string   "barcode"
  end

  create_table "commodities", force: true do |t|
    t.string   "no"
    t.string   "name"
    t.integer  "goodstype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "desc"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts_relationships", id: false, force: true do |t|
    t.integer "contact_id",      null: false
    t.integer "relationship_id", null: false
  end

  add_index "contacts_relationships", ["contact_id", "relationship_id"], name: "index_contacts_relationships_on_contact_id_and_relationship_id", unique: true

  create_table "deliver_notices", force: true do |t|
    t.integer  "order_id"
    t.string   "status"
    t.string   "send_type"
    t.integer  "send_times", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goodstypes", force: true do |t|
    t.string   "gtno"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  create_table "interface_infos", force: true do |t|
    t.string   "method_name"
    t.string   "class_name"
    t.string   "status"
    t.string   "url"
    t.string   "url_method"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_time"
    t.string   "last_time"
    t.text     "url_request"
    t.text     "url_response"
    t.string   "operate_type"
    t.string   "operate_user"
    t.integer  "operate_times"
    t.string   "params",        limit: 1000
  end

  create_table "keyclientorderdetails", force: true do |t|
    t.integer  "keyclientorder_id"
    t.integer  "specification_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount"
    t.string   "batch_no"
    t.integer  "supplier_id"
    t.integer  "business_id"
  end

  create_table "keyclientorders", force: true do |t|
    t.string   "keyclient_name"
    t.string   "keyclient_addr"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "batch_no"
    t.integer  "unit_id"
    t.integer  "storage_id"
    t.integer  "business_id"
    t.integer  "user_id"
    t.string   "status"
    t.string   "barcode"
    t.string   "no"
  end

  create_table "manual_stock_details", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.string   "status"
    t.integer  "amount"
    t.integer  "manual_stock_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manual_stocks", force: true do |t|
    t.string   "no"
    t.string   "name"
    t.string   "desc"
    t.string   "status"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.integer  "storage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "barcode"
  end

  create_table "order_details", force: true do |t|
    t.string   "name",                default: "", null: false
    t.integer  "specification_id"
    t.integer  "amount"
    t.float    "price"
    t.string   "batch_no"
    t.integer  "supplier_id"
    t.integer  "order_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_deliver_no"
  end

  create_table "order_details_stock_logs", id: false, force: true do |t|
    t.integer "order_detail_id", null: false
    t.integer "stock_log_id",    null: false
  end

  add_index "order_details_stock_logs", ["order_detail_id", "stock_log_id"], name: "od_sl_by_id", unique: true

  create_table "order_returns", force: true do |t|
    t.integer  "order_detail_id"
    t.string   "return_reason"
    t.string   "is_bad"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "batch_no"
    t.string   "status"
    t.string   "barcode"
    t.string   "no"
  end

  create_table "orders", force: true do |t|
    t.string   "no",                             default: "",   null: false
    t.string   "order_type"
    t.string   "need_invoice"
    t.string   "customer_name"
    t.string   "customer_unit"
    t.string   "customer_tel"
    t.string   "customer_phone"
    t.string   "customer_address"
    t.string   "customer_postcode"
    t.string   "customer_email"
    t.float    "total_weight"
    t.float    "total_price"
    t.integer  "total_amount"
    t.string   "transport_type"
    t.float    "transport_price"
    t.string   "pay_type"
    t.string   "status"
    t.string   "buyer_desc"
    t.string   "seller_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_id"
    t.integer  "unit_id"
    t.integer  "storage_id"
    t.integer  "keyclientorder_id"
    t.string   "province"
    t.string   "city"
    t.string   "tracking_number"
    t.integer  "user_id"
    t.string   "is_shortage",                    default: "no"
    t.string   "business_order_id"
    t.string   "business_trans_no"
    t.string   "county"
    t.string   "pingan_ordertime"
    t.string   "pingan_operate"
    t.string   "customer_idnumber"
    t.string   "tracking_info",     limit: 2000
    t.string   "barcode"
    t.string   "batch_no"
  end

  create_table "purchase_details", force: true do |t|
    t.string   "name",             default: "", null: false
    t.integer  "purchase_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.string   "qg_period"
    t.string   "batch_no"
    t.integer  "amount"
    t.float    "sum"
    t.string   "desc"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchases", force: true do |t|
    t.string   "no",          default: "", null: false
    t.integer  "unit_id"
    t.integer  "business_id"
    t.integer  "amount"
    t.float    "sum"
    t.string   "desc"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        default: "", null: false
    t.integer  "storage_id"
    t.string   "barcode"
  end

  create_table "relationships", force: true do |t|
    t.integer  "business_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.string   "external_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "spec_desc"
    t.integer  "warning_amt"
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "storage_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["user_id", "storage_id", "role"], name: "index_roles_on_user_id_and_storage_id_and_role", unique: true

  create_table "sequences", force: true do |t|
    t.string   "entity"
    t.integer  "unit_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shelves", force: true do |t|
    t.integer  "area_id"
    t.string   "shelf_code"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority_level"
    t.string   "shelf_row",      default: ""
    t.string   "shelf_column",   default: ""
    t.integer  "max_weight",     default: 0,    null: false
    t.integer  "max_volume",     default: 0,    null: false
    t.string   "area_length",    default: ""
    t.string   "area_width",     default: ""
    t.string   "area_height",    default: ""
    t.string   "barcode"
    t.string   "no"
    t.string   "is_bad",         default: "no"
  end

  create_table "specifications", force: true do |t|
    t.integer  "commodity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "sixnine_code"
    t.string   "desc"
    t.string   "sku"
    t.float    "long"
    t.float    "wide"
    t.float    "high"
    t.float    "weight"
    t.float    "volume"
    t.string   "all_name"
    t.string   "barcode"
    t.string   "no"
  end

  create_table "standard_interfaces", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.string   "operation",               default: "", null: false
    t.string   "status"
    t.integer  "purchase_detail_id"
    t.integer  "amount",                  default: 0,  null: false
    t.datetime "checked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "operation_type"
    t.string   "desc"
    t.integer  "keyclientorderdetail_id"
    t.integer  "manual_stock_detail_id"
  end

  create_table "stocks", force: true do |t|
    t.integer  "shelf_id"
    t.integer  "business_id"
    t.integer  "supplier_id"
    t.string   "batch_no"
    t.integer  "specification_id",             null: false
    t.integer  "actual_amount",    default: 0, null: false
    t.integer  "virtual_amount",   default: 0, null: false
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "storages", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.boolean  "default_storage", default: false
  end

  create_table "suppliers", force: true do |t|
    t.string   "no"
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "barcode"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "no"
    t.string   "short_name"
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",            default: 0,  null: false
    t.string   "operation",          default: "", null: false
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_symbol"
    t.string   "desc"
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
