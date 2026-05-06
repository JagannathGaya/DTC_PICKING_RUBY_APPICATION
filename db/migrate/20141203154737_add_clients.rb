class AddClients < ActiveRecord::Migration[5.1]
  def change
    create_table "clients", force: true do |t|
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
    end

    add_index "clients", ["cust_no"], name: "index_clients_on_cust_no", unique: true, using: :btree
  end
end
