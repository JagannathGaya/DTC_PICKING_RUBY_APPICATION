class AddSalesOrderId < ActiveRecord::Migration[5.1]
  def change
    add_column :tbdash_sales_order_vw, :sales_order_id, :integer, default: 0, null: false
    add_column :tbdash_sales_order_item_vw, :sales_order_id, :integer, default: 0, null: false
    add_column :tbdash_ship_cont_dtl_vw, :sales_order_id, :integer, default: 0, null: false
    drop_table :tbdash_ship_cont_vw
  end
end
