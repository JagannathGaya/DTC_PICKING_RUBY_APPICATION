class AddIdToOraUvws < ActiveRecord::Migration[5.1]
  def change
    add_column :tbpick_move_uvw, :id, :integer
    add_column :tbpick_order_line_uvw, :id, :integer
    add_column :tbpick_wave_uvw, :id, :integer
  end
end
