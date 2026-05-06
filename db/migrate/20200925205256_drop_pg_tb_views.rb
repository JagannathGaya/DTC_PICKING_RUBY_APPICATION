class DropPgTbViews < ActiveRecord::Migration[6.0]
  def up
    drop_table "tb_aisle"
    drop_table "tb_aisle_row"
    drop_table "tb_area_shortcuts"
    drop_table "tb_area_struct"
    drop_table "tbdash_items_vw"
    drop_table "tbdash_sales_order_item_vw"
    drop_table "tbdash_sales_order_vw"
    drop_table "tbdash_ship_cont_dtl_vw"
    drop_table "tbpick_bulk_stock_locs_vw"
    drop_table "tbpick_move_uvw"
    drop_table "tbpick_order_line_uvw"
    drop_table "tbpick_order_lines_vw"
    drop_table "tbpick_orders_vw"
    drop_table "tbpick_wave_uvw"
  end
  def down

  end
end
