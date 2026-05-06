class PickMove < TbpUvw
  self.table_name = 'tbpick_move_uvw'
  set_date_columns :move_date if ActiveRecord::Base.connection.respond_to? :set_date_columns

end