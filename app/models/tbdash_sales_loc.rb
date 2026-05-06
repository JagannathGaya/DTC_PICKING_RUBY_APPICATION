class TbdashSalesLoc < TbpLov
  self.table_name = 'tbpick_arlocation_vw'
  self.primary_key = 'sls_location'

  scope :ordered, -> { order(:sls_location) }

end

# sls_location                              not null varchar2(5)
# name                                      not null varchar2(30)
# lov_id                                    not null varchar2(5)
# lov_label                                 not null varchar2(30)
# lov_sort                                  not null varchar2(5)
