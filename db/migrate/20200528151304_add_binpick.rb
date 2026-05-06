class AddBinpick < ActiveRecord::Migration[6.0]
  def change
    create_table "binpick_batches", force: :cascade do |t|
      t.integer  "client_id", null: false
      t.integer  "user_id", null: false  # user who currently manages batch
      t.integer  "lock_version",             default: 0, null: false
      t.string   "status", default: 'I', null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_column :users, :binpick_batch_id, :integer

  end
end
