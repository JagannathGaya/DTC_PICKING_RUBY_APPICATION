class BinpickReplenishment < TbpUvw

  self.table_name = 'tbpick_batch_replenish_uvw'
  self.primary_key = 'id'

  scope :ordered, -> { order(:row_type).order(:item_no).order(from_qoh: :desc)}
  PICK = 'PICK'
  PUTAWAY = 'PUTAWAY'

end

#
# STOCK_AREA                                NOT NULL VARCHAR2(4)
# BIN_LOC                                   NOT NULL VARCHAR2(11)
# BIN_QTY                                            NUMBER(11,3)
# ITEM_NO                                   NOT NULL VARCHAR2(20)
# DESCRIPTION                               NOT NULL VARCHAR2(30)
# TOTAL_REQUIRED                                     NUMBER
# NET_REQUIRED                                       NUMBER
# FROM_STOCK_AREA                           NOT NULL VARCHAR2(4)
# FROM_BIN_LOC                              NOT NULL VARCHAR2(11)
# FROM_QOH                                           NUMBER(11,3)
# TRANS_QTY                                          NUMBER
# EMPNO                                              VARCHAR2(10)
# ID                                        NOT NULL NUMBER
# ROW_TYPE                                           VARCHAR2(7)
# ACTION                                             VARCHAR2(10)
