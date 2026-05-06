class AddClientLocation < ActiveRecord::Migration[6.0]
  def change
    create_table "client_locations", force: :cascade do |t|
      t.integer  "client_id", null: false
      t.string   "sls_location", limit: 255, null: false
      t.string   "name", limit: 255, null: false
      t.integer  "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
