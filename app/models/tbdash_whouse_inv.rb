class TbdashWhouseInv < TbpView

  EXCLUDE_COLUMNS = []


  self.table_name = 'tbdash_whouse_inv_vw'
  self.primary_key = 'item_slug'

  scope :ordered, -> { order(is_default: :desc).order(:area_bin)}

end

# item_no                                   not null varchar2(20)
# item_slug                                 not null varchar2(20)
# description                               not null varchar2(30)
# stock_um                                  not null varchar2(4)
# status_flag                                        varchar2(8)
# discontinue_flag                                   varchar2(3)
# vendor_name                                        varchar2(41)
# area_bin                                           varchar2(16)
# qty_on_hand                                        number(11,3)
# is_default                                         char(1)
