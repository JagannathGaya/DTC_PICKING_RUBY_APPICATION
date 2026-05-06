class AddLocToBinpickBatch < ActiveRecord::Migration[6.0]
  def change
    add_column :binpick_batches, :client_location_id, :integer
  end
end
