class AddPermits < ActiveRecord::Migration[5.1]
  def change

    create_table "permits", force: true do |t|
      t.string   "report_name", null: false
      t.integer  "client_id"
      t.integer  "user_id"
      t.boolean  "allow", default: true, null: false
      t.integer  "lock_version", default: 0,  null: false
      t.timestamps
    end

    add_index "permits", ["report_name"], name: "index_permits_on_report_name", using: :btree
    add_index "permits", ["client_id"], name: "index_permits_on_client_id", using: :btree
    add_index "permits", ["user_id"], name: "index_permits_on_user_id", using: :btree

  end
end
