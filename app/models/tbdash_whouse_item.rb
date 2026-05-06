class TbdashWhouseItem < TbpView

  EXCLUDE_COLUMNS = []


  self.table_name = 'tbdash_whouse_items_vw'
  self.primary_key = 'item_slug'
  scope :ordered, -> { order(:item_no)}

end

# item_slug                                 not null varchar2(20)
# item_no                                   not null varchar2(20)
# description                               not null varchar2(30)
# status_flag                                        varchar2(8)
# discontinue_flag                                   varchar2(3)
# wo_info                                            varchar2(4000)
