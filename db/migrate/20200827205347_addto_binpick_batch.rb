class AddtoBinpickBatch < ActiveRecord::Migration[6.0]
  def change
    add_column :binpick_batches, :pick_complete_at, :datetime
    add_column :binpick_batches, :pack_complete_at, :datetime
  end
end
