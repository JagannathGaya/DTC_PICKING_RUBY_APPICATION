class Routings < ActiveRecord::Migration[6.0]
  def change

    create_table "routing_failures", force: :cascade do |t|
      t.datetime "logged_at"
      t.string   "action"
      t.string   "request"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "routing_failures", ["request"], name: "index_routing_failures_on_request", using: :btree
  end
end
