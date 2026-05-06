class RemoveUserBinpickBatch < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :binpick_batch_id
  end
end
