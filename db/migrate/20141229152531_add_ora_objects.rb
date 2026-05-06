class AddOraObjects < ActiveRecord::Migration[5.1]
  def change

    create_table :tbpick_bulk_stock_locs_vw, {:id => false, :force => true} do |t|
      t.string :item_no
      t.string :unit_code
      t.string :plant_code
      t.string :stock_area
      t.string :bin_loc
      t.decimal :qty_on_hand, precision: 11, scale: 3
    end

    create_table :tbpick_orders_vw, {:id => false, :force => true} do |t|
      t.integer :order_no
      t.integer :order_suffix
      t.string :ship_name
      t.string :shipto_country_cd
      t.date :estship_dt
    end

    create_table :tbpick_order_lines_vw, {:id => false, :force => true} do |t|
      t.integer :order_no
      t.integer :order_suffix
      t.string :item_no
      t.string :item_desc
      t.decimal :qty_order, precision: 11, scale: 3
      t.string :stock_area
      t.string :bin_loc
      t.decimal :def_on_hand, precision: 11, scale: 3
      t.decimal :other_on_hand, precision: 11, scale: 3
    end

    create_table :tbpick_move_uvw, {:id => false, :force => true} do |t|
      t.integer :wave_id
      t.string :empno
      t.string :item_no
      t.decimal :qty_moved, precision: 11, scale: 3
      t.date :move_date
      t.string :from_stock_area
      t.string :to_stock_area
      t.string :from_bin_loc
      t.string :to_bin_loc
    end

    create_table :tbpick_order_line_uvw, {:id => false, :force => true} do |t|
      t.integer :wave_id
      t.string :empno
      t.integer :order_no
      t.integer :order_suffix
      t.string :item_no
      t.decimal :qty_picked, precision: 11, scale: 3
      t.string :stock_area
      t.string :bin_loc
      t.date :pick_date
    end

    create_table :tbpick_wave_uvw, {:id => false, :force => true} do |t|
      t.string :empno
      t.integer :wave_id
      t.date :pick_date
    end

    create_table :tb_aisle, {:id => false, :force => true} do |t|
      t.string :stock_area
      t.integer :aisle_num
      t.string :aisle
      t.string :pref_direction
    end

    create_table :tb_aisle_row, {:id => false, :force => true} do |t|
      t.string :stock_area
      t.string :row_id
      t.integer :aisle_num
    end

    create_table :tb_area_shortcuts, {:id => false, :force => true} do |t|
      t.string :stock_area
      t.integer :shortcut
    end

    create_table :tb_area_struct, {:id => false, :force => true} do |t|
      t.string :unit_code
      t.string :plant_code
      t.string :stock_area
      t.integer :sec_range_lo
      t.integer :sec_range_hi
      t.integer :xdir_sections
    end

    create_table :tbdash_items_vw, {:id => false, :force => true} do |t|
      t.string :buyer_code
      t.string :product_group
      t.string :product_code
      t.string :item_no
      t.string :allowed_item_code
      t.string :description
      t.string :disc_flg
      t.string :discontinue_flag
      t.string :abc_class
      t.string :stock_um
      t.decimal :qty_on_hand, precision: 11, scale: 3
      t.decimal :qty_on_order, precision: 11, scale: 3
      t.decimal :opn_sls_ord, precision: 11, scale: 3
      t.decimal :qty_reserved, precision: 11, scale: 3
      t.decimal :qty_alloc_sales, precision: 11, scale: 3
      t.decimal :qty_alloc_mfg, precision: 11, scale: 3
      t.decimal :available, precision: 11, scale: 3
      t.string :status_flag
      t.string :status_disc
      t.string :allocation_level
      t.decimal :allocation_quantity, precision: 11, scale: 3
      t.string :wco_hs_code
      t.decimal :avgusage, precision: 11, scale: 3
      t.decimal :reorder_pt, precision: 11, scale: 3
      t.decimal :safety_stock, precision: 11, scale: 3
      t.decimal :base_list_price, precision: 12, scale: 5
      t.decimal :accum_material, precision: 13, scale: 5
      t.decimal :value, precision: 11, scale: 2
      t.string :desc1
      t.string :desc2
      t.string :make_buy_flag
      t.string :flags
      t.decimal :order_point, precision: 11, scale: 3
      t.decimal :order_qty, precision: 11, scale: 3
      t.decimal :eoq, precision: 11, scale: 3
      t.date :date_reported
      t.decimal :last_mo_book, precision: 11, scale: 3
      t.decimal :last_mo_used, precision: 11, scale: 3
      t.decimal :qoh_reorderpt, precision: 11, scale: 3
      t.decimal :ext_price, precision: 11, scale: 2
      t.date :date_updated
      t.decimal :ytd_shipped, precision: 11, scale: 3
      t.string :vendor_name
      t.string :product_group_desc
      t.string :product_code_desc
    end

  end
end
