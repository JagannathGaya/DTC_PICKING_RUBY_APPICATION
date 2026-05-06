class AddCarriers < ActiveRecord::Migration[5.1]
  def change

    create_table "carrier_alts", force: :cascade do |t|
      t.integer  "carrier_id",                           null: false
      t.string   "carrier_nds",  limit: 255,             null: false
      t.integer  "lock_version",             default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "carrier_alts", ["carrier_nds"], name: "index_carrier_alts_on_carrier_nds", unique: true, using: :btree

    create_table "carriers", force: :cascade do |t|
      t.string   "carrier_cd",   limit: 255,             null: false
      t.string   "name",         limit: 255,             null: false
      t.string   "url",          limit: 255,             null: false
      t.integer  "lock_version",             default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "carriers", ["carrier_cd"], name: "index_carriers_on_carrier_cd", unique: true, using: :btree
  end
end
