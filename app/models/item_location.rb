class ItemLocation < TbpUvw

  self.table_name = 'tb_ff_item_loc_vw'
  self.primary_key = 'item_slug'
  scope :ordered, -> { where('status_flag = ? or qty_on_hand > 0', 'A').order(:ff_schema).order(:item_no).order(:stock_area).order(:bin_loc) }


  def s_d
    self.status_flag + '/' + self.discontinue_flag
  end

  private
end

# item_no                                            varchar2(20)
# description                                        varchar2(30)
# stock_um                                           varchar2(4)
# unit_code                                          varchar2(3)
# plant_code                                         varchar2(2)
# stock_area                                         varchar2(4)
# bin_loc                                            varchar2(11)
# control_no                                         varchar2(20)
# qty_on_hand                                        number(11,3)
# last_count_date                                    date
# status_flag                                        varchar2(1)
# discontinue_flag                                   varchar2(1)
# ff_schema                                          varchar2(10)
