class BinpickBin < TbpUvw
  
  self.table_name = 'tbpick_batch_bin_uvw'
  self.primary_key = 'id'

  PICKABLE = 'BIN PICK'
  WAVE_PICK = 'WAVE PICK'
  ALL_ORDERS = 'ALL ORDERS'
  COMPLETE = 'C'
  OPEN = 'O'

  has_many :binpick_bin_items
  has_many :binpick_order_lines

  scope :for_batch, -> (batch_id) {where(binpick_batch_id: batch_id)}
  scope :for_employee, -> (empno) { where(empno: empno)}
  # scope :pickable_bin, -> {where(pick_type: 'BIN PICK')}
  scope :assigned, -> {where(assigned_yn: 'Y', status: 'O')}
  scope :completed, -> {where( status: 'C')}
  scope :scopen, ->  {where( "status in ('O','D')")}
  scope :for_pick_type, -> (type) {where(pick_type: type)}
  scope :wave_pick, -> {where(pick_type: WAVE_PICK)}
  scope :ordered, -> {order(:bin_seq)}
  
  paginates_per 10

  STATUS_VALUES = %w(O D C X)
  validates :status, inclusion: {in: STATUS_VALUES, allow_blank: false}

  STATUS_LIST = [
      ['Open', 'O'],
      ['Complete', 'C'],
      ['Deferred', 'D'],
      ['Cancelled', 'X'],
      ['All', 'A']]

  def completed?  # added ? to avoid confusion with scope of same name
    self.status == COMPLETE
  end

  def open?
    self.status == OPEN
  end

  def pick_all_orders?
    self.pick_type == ALL_ORDERS
  end

end
private
# ID                                        NOT NULL NUMBER
# BINPICK_BATCH_ID                          NOT NULL NUMBER
# BIN_SEQ                                   NOT NULL NUMBER
# STOCK_AREA                                NOT NULL VARCHAR2(4)
# BIN_LOC                                   NOT NULL VARCHAR2(11)
# ORDER_COUNT                                        NUMBER
# LINE_COUNT                                         NUMBER
# PICK_QTY                                           NUMBER(11,3)
# OPEN_QTY                                           NUMBER
# BIN_TYPE                                  NOT NULL VARCHAR2(10)
# PICK_TYPE                                          VARCHAR2(10)
# EMPNO                                              VARCHAR2(10)
# STATUS                                    NOT NULL VARCHAR2(1)
# ASSIGNED_YN                                        CHAR(1)
# AREA_BIN                                           VARCHAR2(16)
# EMPNO_NAME                                         VARCHAR2(62)
