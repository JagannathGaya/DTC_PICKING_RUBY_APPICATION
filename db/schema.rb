# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_06_24_221753) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "binpick_batches", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "user_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "status", default: "I", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "start_order_seq", default: 0, null: false
    t.integer "end_order_seq", default: 0, null: false
    t.datetime "pick_complete_at"
    t.datetime "pack_complete_at"
    t.integer "client_location_id"
    t.string "bo_option", default: "A", null: false
    t.index ["client_id"], name: "index_binpick_batches_on_client_id"
    t.index ["client_location_id"], name: "index_binpick_batches_on_client_location_id"
    t.index ["user_id"], name: "index_binpick_batches_on_user_id"
  end

  create_table "carrier_alts", force: :cascade do |t|
    t.integer "carrier_id", null: false
    t.string "carrier_nds", limit: 255, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["carrier_nds"], name: "index_carrier_alts_on_carrier_nds", unique: true
  end

  create_table "carriers", force: :cascade do |t|
    t.string "carrier_cd", limit: 255, null: false
    t.string "name", limit: 255, null: false
    t.string "url", limit: 255, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["carrier_cd"], name: "index_carriers_on_carrier_cd", unique: true
  end

  create_table "client_locations", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "sls_location", limit: 255, null: false
    t.string "name", limit: 255, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", force: :cascade do |t|
    t.string "cust_no", null: false
    t.string "cust_name", null: false
    t.string "email", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "database"
    t.string "username"
    t.string "password"
    t.string "client_manager_email"
    t.boolean "allow_combined", default: true, null: false
    t.index ["cust_no"], name: "index_clients_on_cust_no", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "makers", force: :cascade do |t|
    t.string "name", null: false
    t.string "exec", null: false
    t.hstore "options", default: {}, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_makers_on_name", unique: true
  end

  create_table "page_requests", force: :cascade do |t|
    t.string "controller"
    t.string "action"
    t.string "format"
    t.string "method"
    t.string "path"
    t.integer "status"
    t.decimal "page_runtime", precision: 10, scale: 3, default: "0.0"
    t.decimal "view_runtime", precision: 10, scale: 3, default: "0.0"
    t.decimal "db_runtime", precision: 10, scale: 3, default: "0.0"
    t.date "action_date"
    t.integer "action_hour"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["action_date", "action_hour"], name: "index_page_requests_on_when"
    t.index ["controller"], name: "index_page_requests_on_controller"
  end

  create_table "permits", force: :cascade do |t|
    t.string "report_name", null: false
    t.integer "client_id"
    t.integer "user_id"
    t.boolean "allow", default: true, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_permits_on_client_id"
    t.index ["report_name"], name: "index_permits_on_report_name"
    t.index ["user_id"], name: "index_permits_on_user_id"
  end

  create_table "picks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "pick_type", null: false
    t.string "sort_key", null: false
    t.string "action_seq", null: false
    t.string "path"
    t.string "item_no", null: false
    t.decimal "pick_qty", precision: 11, scale: 3, default: "0.0", null: false
    t.string "pick_area", null: false
    t.string "pick_bin", null: false
    t.string "moveto_area"
    t.string "moveto_bin"
    t.integer "order_no"
    t.integer "order_suffix"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "actual_qty", precision: 11, scale: 3, default: "0.0", null: false
    t.integer "client_id", null: false
    t.integer "wave_id", null: false
    t.integer "line_no", default: 0, null: false
    t.index ["client_id"], name: "index_picks_on_client_id"
    t.index ["item_no"], name: "index_picks_on_item_no"
    t.index ["pick_type", "sort_key", "action_seq"], name: "index_picks_on_sort_order"
    t.index ["user_id"], name: "index_picks_on_user_id"
    t.index ["wave_id"], name: "index_picks_on_wave_id"
  end

  create_table "receipt_batches", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "note", limit: 255
    t.string "batch_status", limit: 255, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "tracking_ref", limit: 255
    t.datetime "dock_receipt_at"
    t.string "vendor_no", limit: 255, null: false
    t.integer "receipt_upload_hdr_id"
    t.string "empno"
    t.string "po_ref", limit: 30
    t.index ["client_id"], name: "index_receipt_batches_on_client_id"
  end

  create_table "receipt_items", id: :serial, force: :cascade do |t|
    t.integer "receipt_batch_id", null: false
    t.string "item_no", limit: 255
    t.integer "boxcount", default: 1, null: false
    t.string "empno", limit: 255, null: false
    t.integer "quantity", default: 1, null: false
    t.boolean "searched", default: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "note", limit: 255
    t.boolean "discontinue_flag", default: false
    t.boolean "status_flag", default: false
    t.string "description", limit: 255
    t.boolean "mute", default: false
    t.integer "label_copies", default: 1
    t.string "comment", limit: 255
    t.string "vendor_id"
    t.string "po_no"
    t.string "shipment_no"
    t.string "shipment_line"
    t.string "shipment_date"
    t.integer "qty_shipped"
    t.index ["receipt_batch_id"], name: "index_receipt_batches_on_receipt_batch_id"
  end

  create_table "receipt_locations", id: :serial, force: :cascade do |t|
    t.integer "receipt_item_id", null: false
    t.string "stock_area", limit: 255, null: false
    t.string "bin_loc", limit: 255, null: false
    t.integer "quantity", default: 1, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "fast_reference"
    t.boolean "new_default", default: false
    t.string "loc_type", limit: 255
    t.index ["receipt_item_id"], name: "index_receipt_locations_on_receipt_item_id"
  end

  create_table "routing_failures", force: :cascade do |t|
    t.datetime "logged_at"
    t.string "action"
    t.string "request"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "logfile"
    t.index ["request"], name: "index_routing_failures_on_request"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "empno"
    t.string "time_zone"
    t.string "locale"
    t.string "user_type", default: "user"
    t.integer "lock_version", default: 0, null: false
    t.integer "client_id"
    t.string "api_key"
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "waves", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
    t.string "order_list", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_waves_on_client_id"
    t.index ["user_id"], name: "index_waves_on_user_id"
  end

end
