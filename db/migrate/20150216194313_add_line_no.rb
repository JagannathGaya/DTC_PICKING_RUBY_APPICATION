class AddLineNo < ActiveRecord::Migration[5.1]
  def change
    add_column :picks, :line_no, :integer, default: 0, null: false
    add_column :tbpick_order_line_uvw, :line_no, :integer, default: 0, null: false
    add_column :tbpick_order_lines_vw, :line_no, :integer, default: 0, null: false
  end
end
