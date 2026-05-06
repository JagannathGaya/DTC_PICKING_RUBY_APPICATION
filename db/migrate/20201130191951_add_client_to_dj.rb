class AddClientToDj < ActiveRecord::Migration[6.0]
  def change
    add_column :delayed_jobs,:client_id, :integer
  end
end
