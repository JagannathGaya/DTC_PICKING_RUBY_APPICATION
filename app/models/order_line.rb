class OrderLine < TbpView
  self.table_name = 'tbpick_order_lines_vw'
  self.primary_key = 'line_no'
  scope :ordered, -> { order(:item_no).order(:stock_area).order(:bin_loc).order(:order_no) }
  scope :for_order_list, -> (list) { list.length != 0 ? where("order_no in (#{list})") : where("1=2") }

  def order_number
    self.order_no.to_s + '-' + self.order_suffix.to_s
  end

end
# order_no, order_suffix, line_no, item_no, item_desc, qty_order, stock_area, bin_loc, def_on_hand, other_on_hand
