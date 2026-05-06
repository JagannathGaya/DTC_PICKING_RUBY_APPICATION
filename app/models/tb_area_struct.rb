class TbAreaStruct < TbpView
  self.table_name = 'tb_area_struct'
  self.primary_key = 'stock_area'
  scope :ordered, -> { order(:stock_area) }
  scope :for_area, -> (area) { where(stock_area: area) }

end
# unit_code, plant_code, stock_area, sec_range_lo, sec_range_hi, xdir_sections ('100', '10', 'AS', 1, 20, 8)
