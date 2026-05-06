class Receivers < ActiveRecord::Migration[6.0]
  def change
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
  end
end
