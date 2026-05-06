class AddSubsModUsers < ActiveRecord::Migration[5.1]
  def change
    enable_extension "hstore"

    add_column :users, :client_id, :integer


    create_table "makers", force: true do |t|
      t.string   "name",                      null: false
      t.string   "exec",                      null: false
      t.hstore   "options",      default: {}, null: false
      t.integer  "lock_version", default: 0,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "makers", ["name"], name: "index_makers_on_name", unique: true, using: :btree

    create_table "subscriptions", force: true do |t|
      t.integer  "maker_id",                     null: false
      t.integer  "user_id",                      null: false
      t.boolean  "active",       default: false, null: false
      t.hstore   "options",      default: {},    null: false
      t.integer  "disposition",  default: 0,     null: false
      t.integer  "frequency",    default: 0,     null: false
      t.integer  "format",       default: 0,     null: false
      t.datetime "next_run"
      t.integer  "lock_version", default: 0,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "client_id"
    end

    add_index "subscriptions", ["next_run"], name: "index_subscriptions_on_next_run", using: :btree
    add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  end
end
