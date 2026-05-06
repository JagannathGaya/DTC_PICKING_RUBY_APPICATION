class AddWaveTable < ActiveRecord::Migration[5.1]
  def change
    Pick.delete_all
    create_table 'waves', force: true do |t|
      t.integer 'user_id', null: false
      t.integer 'client_id', null: false
      t.string 'order_list', null: false
      t.integer 'lock_version', default: 0, null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_index 'waves', ['user_id'], name: 'index_waves_on_user_id', using: :btree
    add_index 'waves', ['client_id'], name: 'index_waves_on_client_id', using: :btree

    add_column :picks, :client_id, :integer, null: false
    add_index 'picks', ['client_id'], name: 'index_picks_on_client_id', using: :btree

    add_column :picks, :wave_id, :integer, null: false
    add_index 'picks', ['wave_id'], name: 'index_picks_on_wave_id', using: :btree

  end
end
