class TbdashItemHist < TbpView

  EXCLUDE_COLUMNS = []
  set_date_columns :trans_date, :trans_date_utc if ActiveRecord::Base.connection.respond_to? :set_date_columns


  self.table_name = 'tbdash_item_hist_vw'
  self.primary_key = 'item_slug'
  scope :ordered, -> { order(:item_no).order(trans_date: :desc) }


end

# item_no                                   not null varchar2(20)
# trans_date                                not null date
# trans_date_utc                                     date
# trans_type                                not null varchar2(1)
# trans_type_desc                                    varchar2(50)
# trans_qty                                          number(11,3)
# stock_area                                         varchar2(4)
# bin_loc                                            varchar2(11)
# reason_code                                        varchar2(10)
# reason_desc                                        varchar2(50)
# ref_order                                          varchar2(10)
# item_slug                                 not null varchar2(20)
# empno                                              varchar2(10)
# area_bin                                           varchar2(16)
# ref_remark                                         varchar2(30)
# current_loc                                        char(1)
# emp_name
