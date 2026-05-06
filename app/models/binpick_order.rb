class BinpickOrder < TbpUvw

  self.table_name = 'tbpick_batch_order_uvw'
  self.primary_key = 'id'

  has_many :binpick_order_lines
  scope :for_batch, -> (batch_id) { where(binpick_batch_id: batch_id) }
  scope :ordered, -> { order(:order_seq) }
  SIZE_LIST = [['All', 'A'],
               ['Lge', 'Y'],
               ['Std', 'N']]
  WAVE_LIST = [['All', 'A'],
               ['Yes', 'Y'],
               ['None', 'N']]
  STATUS_LIST = ['ALL','VALID','INVALID','CONFIRMED']

  def order_display
    self.order_no.to_i.to_s + '-' + self.order_suffix.to_i.to_s
  end

end

# ID                                        NOT NULL NUMBER
# BINPICK_BATCH_ID                          NOT NULL NUMBER
# ORDER_SEQ                                 NOT NULL NUMBER
# ORDER_NO                                  NOT NULL NUMBER(10)
# ORDER_SUFFIX                              NOT NULL NUMBER(2)
# INITIAL_BIN_SEQ                                    NUMBER
# LARGE_ORDER_YN                            NOT NULL VARCHAR2(1)
# SHIP_NAME                                          VARCHAR2(30)
# TOTAL_QTY                                          NUMBER
# LINE_COUNT                                         NUMBER
# HAS_WAVE_PICK_YN                                   CHAR(1)
# SHIPPING_STATUS                                    VARCHAR2(7)
# BIN_STATUS                                         VARCHAR2(1)