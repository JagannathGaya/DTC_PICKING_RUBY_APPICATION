class ModPicks < ActiveRecord::Migration[5.1]
  def change
    add_column :picks, :actual_qty, :decimal, precision: 11, scale: 3, default: 0, null: false
  end
end
