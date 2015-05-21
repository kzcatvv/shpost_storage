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

ActiveRecord::Schema.define(version: 20150521015426) do

  create_table "areas", force: true do |t|
    t.integer  "storage_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "area_code",  default: "", null: false
    t.string   "name",       default: "", null: false
    t.string   "area_type"
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
    t.string   "english_name"
    t.string   "name_en"
  end

  create_table "constock_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "consumable_stock_id"
    t.integer  "amount"
    t.string   "operation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consumable_stocks", force: true do |t|
    t.integer  "consumable_id"
    t.string   "shelf_name"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.integer  "storage_id"
  end

  create_table "consumables", force: true do |t|
    t.integer  "business_id"
    t.integer  "supplier_id"
    t.string   "name"
    t.string   "spec_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.integer  "storage_id"
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

  create_table "country_codes", force: true do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "code"
    t.string   "surfmail_partition_no"
    t.string   "regimail_partition_no"
    t.boolean  "is_mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deliver_notices", force: true do |t|
    t.integer  "order_id"
    t.string   "status"
    t.string   "send_type"
    t.integer  "send_times", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gjxbgs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gjxbps", force: true do |t|
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
    t.string   "business_id"
    t.string   "unit_id"
    t.string   "storage_id"
    t.string   "request_ip"
    t.string   "response_ip"
  end

  create_table "inventories", force: true do |t|
    t.string   "no"
    t.integer  "unit_id"
    t.string   "desc"
    t.string   "name"
    t.string   "inv_type"
    t.integer  "storage_id"
    t.string   "barcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inv_type_dtl"
    t.string   "status"
    t.string   "goods_inv_type"
    t.string   "goods_inv_dtl"
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
    t.string   "order_type",     default: "b2c"
  end

  create_table "logistics", force: true do |t|
    t.string   "name"
    t.string   "print_format"
    t.boolean  "is_getnum"
    t.string   "contact"
    t.string   "address"
    t.string   "contact_phone"
    t.string   "post"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "param_val1"
    t.string   "param_val2"
    t.string   "wl_no"
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
    t.string   "defective",        default: "0"
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
    t.string   "virtual",     default: "0"
  end

  create_table "mobile_logs", force: true do |t|
    t.string   "status"
    t.string   "operate_type"
    t.string   "request_ip"
    t.string   "response_ip"
    t.integer  "user_id"
    t.integer  "storage_id"
    t.integer  "unit_id"
    t.integer  "mobile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "request"
    t.text     "response"
    t.text     "request_params"
  end

  create_table "mobiles", force: true do |t|
    t.string   "no"
    t.string   "mobile_type"
    t.string   "version"
    t.integer  "user_id"
    t.integer  "storage_id"
    t.datetime "last_sign_in_time"
    t.boolean  "cancel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "move_stocks", force: true do |t|
    t.string   "no"
    t.integer  "unit_id"
    t.integer  "amount"
    t.float    "sum"
    t.string   "desc"
    t.string   "status"
    t.string   "name"
    t.integer  "storage_id"
    t.string   "barcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_details", force: true do |t|
    t.string   "name",                default: ""
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
    t.string   "is_shortage"
    t.string   "from_country"
    t.float    "weight"
    t.string   "defective",           default: "0"
  end

  create_table "order_details_stock_logs", id: false, force: true do |t|
    t.integer "order_detail_id", null: false
    t.integer "stock_log_id",    null: false
  end

  add_index "order_details_stock_logs", ["order_detail_id", "stock_log_id"], name: "od_sl_by_id", unique: true

  create_table "order_return_details", force: true do |t|
    t.integer  "order_return_id", limit: 255
    t.integer  "order_detail_id", limit: 255
    t.string   "return_reason"
    t.string   "is_bad"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "order_returns", force: true do |t|
    t.integer  "unit_id",    limit: 255
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "storage_id", limit: 255
    t.string   "status"
    t.string   "barcode"
    t.string   "no"
    t.string   "batch_no"
  end

  create_table "orders", force: true do |t|
    t.string   "no",                             default: ""
    t.string   "order_type",                     default: "b2c"
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
    t.string   "tracking_info",     limit: 4000
    t.string   "barcode"
    t.string   "batch_no"
    t.integer  "parent_id"
    t.boolean  "is_split",                       default: false
    t.float    "volume"
    t.datetime "out_at"
    t.string   "api_key"
    t.string   "exps_guid"
    t.string   "exps_reg"
    t.string   "exps_type"
    t.string   "country"
    t.string   "local_name"
    t.string   "local_country"
    t.string   "local_province"
    t.string   "local_city"
    t.string   "local_addr"
    t.string   "send_province"
    t.string   "send_city"
    t.string   "logistic_id"
    t.string   "country_code"
    t.string   "send_addr"
    t.string   "send_name"
    t.string   "send_zip"
    t.string   "send_mobile"
    t.boolean  "is_printed",                     default: false
    t.string   "virtual",                        default: "0"
  end

  create_table "orders_user_logs", id: false, force: true do |t|
    t.integer "order_id",    null: false
    t.integer "user_log_id", null: false
  end

  create_table "purchase_arrivals", force: true do |t|
    t.integer  "arrived_amount"
    t.date     "expiration_date"
    t.date     "arrived_at"
    t.string   "batch_no"
    t.integer  "purchase_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "purchase_details", force: true do |t|
    t.string   "name",                         default: "",  null: false
    t.integer  "purchase_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.date     "expiration_date",  limit: 255
    t.string   "batch_no"
    t.integer  "amount"
    t.float    "sum"
    t.string   "desc"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "defective",                    default: "0"
  end

  create_table "purchases", force: true do |t|
    t.string   "no",          default: "",  null: false
    t.integer  "unit_id"
    t.integer  "business_id"
    t.integer  "amount"
    t.float    "sum"
    t.string   "desc"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        default: "",  null: false
    t.integer  "storage_id"
    t.string   "barcode"
    t.string   "virtual",     default: "0"
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
    t.string   "barcode"
    t.boolean  "piece_to_piece",   default: false
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "storage_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["user_id", "storage_id", "role"], name: "index_roles_on_user_id_and_storage_id_and_role", unique: true

  create_table "sequence_nos", force: true do |t|
    t.integer "unit_id"
    t.integer "storage_id"
    t.integer "logistic_id"
    t.integer "start_no",    limit: 255
    t.integer "end_no",      limit: 255
    t.string  "storage_no"
  end

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
    t.integer  "max_weight",     default: 0,  null: false
    t.integer  "max_volume",     default: 0,  null: false
    t.string   "area_length",    default: ""
    t.string   "area_width",     default: ""
    t.string   "area_height",    default: ""
    t.string   "barcode"
    t.string   "no"
    t.string   "shelf_type"
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
    t.boolean  "piece_to_piece"
    t.string   "english_name"
    t.string   "name_en"
    t.float    "price"
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
    t.integer  "shelf_id"
    t.integer  "business_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.date     "expiration_date"
    t.string   "batch_no"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "pick_id"
    t.integer  "relationship_id"
    t.string   "sn"
    t.integer  "check_amount",            default: 0
  end

  create_table "stock_mons", force: true do |t|
    t.string   "summ_date"
    t.integer  "storage_id"
    t.integer  "business_id"
    t.integer  "supplier_id"
    t.integer  "specification_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.date     "expiration_date"
    t.string   "sn"
    t.integer  "relationship_id"
  end

  create_table "storages", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.boolean  "default_storage", default: false
    t.string   "address"
    t.string   "phone"
    t.string   "postcode"
    t.string   "tcbd_product_no"
    t.string   "no"
    t.boolean  "need_pick",       default: false
    t.string   "return_unit",     default: "上海市邮政公司物流分公司"
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
    t.string   "business_id"
    t.string   "business_code"
  end

  create_table "tasks", force: true do |t|
    t.string   "title"
    t.string   "barcode"
    t.string   "task_type"
    t.string   "status"
    t.string   "code"
    t.integer  "storage_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "assign_type"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "no"
    t.string   "short_name"
    t.string   "tcbd_khdh"
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "up_downloads", force: true do |t|
    t.string   "name"
    t.string   "use"
    t.string   "desc"
    t.string   "ver_no"
    t.string   "url"
    t.datetime "oper_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",            default: 0,  null: false
    t.string   "operation",          default: "", null: false
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "object_symbol"
    t.string   "desc"
    t.integer  "parent_id"
    t.string   "parent_type"
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
