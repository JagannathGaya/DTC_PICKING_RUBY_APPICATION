class AddStartOrderSeq < ActiveRecord::Migration[6.0]
  def change
    add_column :binpick_batches, :start_order_seq, :integer, default: 0, null: false
    add_column :binpick_batches, :end_order_seq, :integer, default: 0, null: false
  end
end
