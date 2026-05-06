class TbdashRecvPutawayLoc < TbpView

  EXCLUDE_COLUMNS = []

  self.table_name = 'tbdash_recv_putaway_loc_vw'
  self.primary_key = 'item_no'

  scope :ordered, -> { order(:precedence).order(:stock_area).order(:bin_loc) }

end

# select a.item_no, a.unit_code, a.plant_code, a.stock_area
# , a.bin_loc, 'DEFAULT' loc_type, sum(nvl(c.qty_on_hand,0)) qty_on_hand, 1 precedence