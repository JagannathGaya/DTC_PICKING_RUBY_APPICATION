class BulkStockLoc < TbpView
  self.table_name = 'tbpick_bulk_stock_locs_vw'
  self.primary_key = 'item_no'
  scope :ordered, -> { order(:stock_area).order(:bin_loc) }


end

# item_no, unit_code, plant_code, stock_area, bin_loc, qty_on_hand
