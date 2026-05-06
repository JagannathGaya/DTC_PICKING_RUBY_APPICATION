class AddSalesOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :tbdash_sales_order_vw, {:id => false, :force => true} do |t|
      t.decimal :order_no, precision: 10
      t.decimal :order_suffix, precision: 3
      t.string  :plant_code
      t.date    :order_utc
      t.date    :estship_utc
      t.string  :cllient_order_no
      t.string  :cust_po
      t.string  :cust_no
      t.string  :cust_name
      t.string  :ship_name
      t.string  :ship_attn
      t.string  :ship_addr1
      t.string  :ship_addr2
      t.string  :shipto_city
      t.string  :shipto_state
      t.string  :shipto_zip
      t.string  :shipto_country_cd
      t.string  :carrier_id
      t.string  :pro_number
      t.string  :bill_of_lading
      t.decimal :gross_wt, precision: 14, scale: 5
      t.string  :order_status
      t.string  :status_desc
      t.decimal :container_count, precision: 8
    end

    create_table :tbdash_sales_order_item_vw, {:id => false, :force => true} do |t|
      t.decimal :order_no, precision: 10
      t.decimal :order_suffix, precision: 3
      t.string  :cust_no
      t.string  :item_no
      t.string  :item_desc
      t.string  :cust_item_no
      t.string  :sales_um
      t.decimal :qty_order, precision: 11, scale: 3
      t.decimal :qty_shipped, precision: 11, scale: 3
      t.decimal :qty_bo, precision: 11, scale: 3
      t.date    :due_date_utc
      t.string  :ship_name
      t.string  :control_type
    end

    create_table :tbdash_ship_cont_vw, {:id => false, :force => true} do |t|
      t.decimal :order_no, precision: 10
      t.decimal :order_suffix, precision: 3
      t.string  :cust_no
      t.decimal :container_no, precision:4
      t.string  :container_id
      t.string  :carrier_id
      t.decimal :gross_wt, precision: 14, scale: 5
      t.string  :container_type
    end

    create_table :tbdash_ship_cont_dtl_vw, {:id => false, :force => true} do |t|
      t.decimal :order_no, precision: 10
      t.decimal :order_suffix, precision: 3
      t.string  :cust_no
      t.decimal :container_no, precision:4
      t.string  :container_id
      t.string  :carrier_id
      t.decimal :gross_wt, precision: 14, scale: 5
      t.string  :container_type
      t.string  :item_no
      t.string  :item_desc
      t.string  :control_no
      t.decimal :qty_shipped, precision: 11, scale: 3
      t.string  :control_type
    end

  end
end
