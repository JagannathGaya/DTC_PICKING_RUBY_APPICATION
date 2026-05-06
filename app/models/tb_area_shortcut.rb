class TbAreaShortcut < TbpView
  self.table_name = 'tb_area_shortcuts'
  self.primary_key = 'stock_area'
  scope :ordered, -> { order(:stock_area) }
  scope :for_area, -> (area) { where(stock_area: area) }

end
# stock_area, shortcut ( 'AS', 4 );
