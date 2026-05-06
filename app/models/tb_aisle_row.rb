class TbAisleRow < TbpView
  self.table_name = 'tb_aisle_row'
  self.primary_key = 'row_id'
  scope :ordered, -> { order(:stock_area).order(:row_id) }
  scope :for_area, -> (area) { where(stock_area: area) }

end
# stock_area, row_id, aisle_num ('AS', 'A', 1)
