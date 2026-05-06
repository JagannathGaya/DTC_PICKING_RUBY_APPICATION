class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index "binpick_batches", ["client_id"], using: :btree
    add_index "binpick_batches", ["user_id"], using: :btree
    add_index "binpick_batches", ["client_location_id"], using: :btree
  end
end
