class BinpickBinItem < TbpUvw
  attr_accessor :all_orders_exceptions_present

  BACKORDERED = 'B'

  self.table_name = 'tbpick_batch_bin_item_uvw'
  self.primary_key = 'id'

  has_many :binpick_order_lines
  belongs_to :binpick_bin

  scope :pickable_item, -> { where(status: 'O') }
  scope :for_bin, -> (bin_id) { where(binpick_bin_id: bin_id) }
  scope :ordered, -> { order(:item_no) }

  STATUS_VALUES = %w(O C B)
  validates :status, inclusion: {in: STATUS_VALUES, allow_blank: false}

  def item_display
    self.item_no + ' - ' + self.item_desc
  end

  def status_display
    case self.status
    when 'O'
      'Open'
    when 'C'
      'Complete'
    when 'B'
      'Backorder'
    end
  end


  def backordered?
    self.status == BACKORDERED
  end

  def not_backordered?
    !self.backordered?
  end


end

# ID                                        NOT NULL NUMBER
# BINPICK_BIN_ID                            NOT NULL NUMBER
# ITEM_NO                                   NOT NULL VARCHAR2(20)
# ITEM_DESC                                 NOT NULL VARCHAR2(30)
# ORDER_COUNT                                        NUMBER
# LINE_COUNT                                         NUMBER
# PICK_QTY                                           NUMBER(11,3)
# OPEN_QTY                                           NUMBER
# QTY_SHIPPED                                        NUMBER
# QTY_BACKORDERED                                    NUMBER
# BIN_TYPE                                  NOT NULL VARCHAR2(10)
# PICK_TYPE                                          VARCHAR2(10)
# STATUS                                    NOT NULL VARCHAR2(1)
# BINPICK_BATCH_ID                          NOT NULL NUMBER
