class AddPick < ActiveRecord::Migration[5.1]
  def change
    create_table 'picks', force: true do |t|
      t.integer 'user_id', null: false
      t.string 'pick_type', null: false
      t.string 'sort_key', null: false
      t.string 'action_seq', null: false
      t.string 'path'
      t.string 'item_no', null: false
      t.decimal 'pick_qty', precision: 11, scale: 3, default: 0, null: false
      t.string 'pick_area', null: false
      t.string 'pick_bin', null: false
      t.string 'moveto_area'
      t.string 'moveto_bin'
      t.integer 'order_no'
      t.integer 'order_suffix'
      t.integer 'lock_version', default: 0, null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'picks', ['user_id'], name: 'index_picks_on_user_id', using: :btree
    add_index 'picks', ['pick_type','sort_key','action_seq'], name: 'index_picks_on_sort_order', using: :btree
    add_index 'picks', ['item_no'], name: 'index_picks_on_item_no', using: :btree
  end
end
