class BinpickOrderLine < TbpUvw
  self.table_name = 'tbpick_batch_order_line_uvw'
  self.primary_key = 'id'
  paginates_per 10

  BIN_PICK = 'BIN PICK'
  ALL_ORDERS = 'ALL ORDERS'
  WAVE_PICK = 'WAVE_PICK'

  belongs_to :binpick_order
  belongs_to :binpick_bin_item

  scope :for_action, -> (action) { where("? = 'A' OR tbpick_batch_order_line_uvw.action = ?", action, action)}
  scope :scopen, -> { where( action: NOT_PICKED, order_status: SHIPPABLE)}
  scope :shipped, -> { where( action: CONFIRMED, order_status: SHIPPABLE)}
  scope :shippable, -> { where(order_status: SHIPPABLE)}
  scope :qty_exception, -> { where('qty_shipped > 1')}
  scope :backordered, -> { where( action: BACKORDERED, order_status: SHIPPABLE)}
  scope :for_bin, -> (binpick_bin_item_id) {where(binpick_bin_item_id: binpick_bin_item_id, order_status: SHIPPABLE)}
  scope :ordered, -> { order(:order_seq).order(:line_no) }
  scope :for_order, -> (binpick_order_id) {where(binpick_order_id: binpick_order_id)}
  scope :for_bin_item, -> (binpick_bin_item_id) { where(binpick_bin_item_id: binpick_bin_item_id, order_status: SHIPPABLE) }
  scope :for_pick_type, -> (type) {where(pick_type: type)}
  scope :wave_ordered, -> {order(:wave_action_seq, :stock_area, :bin_loc)}
  scope :for_batch, -> (id) {where(binpick_batch_id: id)}

  NOT_PICKED = 'N'
  CONFIRMED = 'S'
  BACKORDERED = 'B'
  SHIPPABLE = 'J'

  ACTION_LIST = [
      ['Open', 'N'],
      ['Shipped', 'S'],
      ['Backorder', 'B'],
      ['Recent', 'R'],
      ['All', 'A']]

  ACTION_VALUES = %w(N S B X)
  validates :action, inclusion: {in: ACTION_VALUES, allow_blank: false}

  def pickable?
    self.action == NOT_PICKED
  end

  def backordered?
    self.action == BACKORDERED
  end

  def item_display
    self.item_no + ' - ' + self.item_desc
  end

  def order_display
    self.order_no.to_i.to_s + '-' + self.order_suffix.to_i.to_s
  end

  def shippable?
    self.order_status == SHIPPABLE
  end
  
end

# ID                                        NOT NULL NUMBER
# BINPICK_ORDER_ID                          NOT NULL NUMBER
# BINPICK_BIN_ITEM_ID                       NOT NULL NUMBER
# LINE_NO                                   NOT NULL NUMBER(4)
# ITEM_NO                                   NOT NULL VARCHAR2(20)
# ITEM_DESC                                 NOT NULL VARCHAR2(50)
# QTY_SHIPPED                                        NUMBER(11,3)
# EMPNO                                              VARCHAR2(10)
# ACTION                                             VARCHAR2(1)
# ORDER_LINE_SEQ                                     NUMBER(8)
# STOCK_AREA                                NOT NULL VARCHAR2(4)
# BIN_LOC                                   NOT NULL VARCHAR2(11)
# PICK_TYPE                                          VARCHAR2(10)
# BIN_TYPE                                  NOT NULL VARCHAR2(10)
# ORDER_NO                                  NOT NULL NUMBER(10)
# ORDER_SUFFIX                              NOT NULL NUMBER(2)
# ORDER_SEQ                                 NOT NULL NUMBER
# BINPICK_BATCH_ID                          NOT NULL NUMBER
# LARGE_ORDER_YN                            NOT NULL VARCHAR2(1)
# MESSAGE                                            CHAR(11)