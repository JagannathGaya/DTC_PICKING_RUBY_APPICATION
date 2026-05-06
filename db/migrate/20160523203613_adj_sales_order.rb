class AdjSalesOrder < ActiveRecord::Migration[5.1]
  def change
    remove_column :tbdash_sales_order_vw, :pro_number
    remove_column :tbdash_sales_order_vw, :bill_of_lading
    add_column :tbdash_sales_order_vw, :service_level, :string
  end
end
