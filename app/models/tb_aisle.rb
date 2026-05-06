class TbAisle < TbpView
  self.table_name = 'tb_aisle'
  self.primary_key = 'aisle_num'
  scope :ordered, -> { order(:stock_area).order(:aisle_num) }
  scope :for_area, -> (area) { where(stock_area: area) }
  scope :for_aisle_num, -> (aisle_num) { where(aisle_num: aisle_num) }

end
# stock_area, aisle_num, aisle, pref_direction ( 'AS', 1, 'A', 'N');
