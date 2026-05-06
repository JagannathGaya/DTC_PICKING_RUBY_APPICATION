class AddMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table "page_requests", force: true do |t|
      t.string   "controller"
      t.string   "action"
      t.string   "format"
      t.string   "method"
      t.string   "path"
      t.integer  "status"
      t.decimal  "page_runtime", precision: 10, scale: 3, default: 0
      t.decimal  "view_runtime", precision: 10, scale: 3, default: 0
      t.decimal  "db_runtime", precision: 10, scale: 3, default: 0
      t.date     "action_date"
      t.integer  "action_hour"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "page_requests", ["controller"], name: "index_page_requests_on_controller"
    add_index "page_requests", ["action_date","action_hour"], name: "index_page_requests_on_when"
  end
end
