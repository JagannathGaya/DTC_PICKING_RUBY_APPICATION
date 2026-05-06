class DropSubscriptions < ActiveRecord::Migration[6.0]
  def change
    drop_table :subscriptions
  end
end
