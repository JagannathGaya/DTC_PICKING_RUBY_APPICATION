class PickOrderLine < TbpUvw
  self.table_name = 'tbpick_order_line_uvw'
  set_date_columns :pick_date if ActiveRecord::Base.connection.respond_to? :set_date_columns

end