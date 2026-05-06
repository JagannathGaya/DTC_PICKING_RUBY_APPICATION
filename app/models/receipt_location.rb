class ReceiptLocation < ApplicationRecord

  scope :ordered, -> {order(:receipt_item_id).order(:id)}
  scope :for_item, -> (receipt_item_id) {where(receipt_item_id: receipt_item_id)}
  scope :for_reversal, -> (receipt_item_id, stock_area, bin_loc) {where(receipt_item_id: receipt_item_id, stock_area: stock_area, bin_loc: bin_loc)}

  belongs_to :receipt_item

  before_save :upcase_fields
  before_create :check_receipt_qty

  validates :receipt_item_id, presence: true
  validates :stock_area, presence: true
  validates :bin_loc, presence: true

  def defloc_action
    return 'Existing' if self.loc_type == 'DEFAULT'
    return 'Updated' if self.new_default
    'No'
  end

  private

  def upcase_fields
    self.stock_area.upcase!
    self.bin_loc.upcase!
  end

  def check_receipt_qty
   puts "ReceiptLocation#check_qty_total remaining = #{self.receipt_item.qty_remaining} this qty = #{self.quantity}"
    return true if self.receipt_item && self.quantity > 0 && (self.receipt_item.qty_remaining - self.quantity) >= 0
    return check_reversal if self.quantity && self.quantity < 0 # fork in the road
    do_error (I18n.t('receipt_location.qty_too_big'))
  end

  def check_reversal
    total_qty = 0
    prev = ReceiptLocation.for_reversal(self.receipt_item_id, self.stock_area, self.bin_loc)
    return do_error(I18n.t('receipt_location.reversal_loc_not_found')) if prev.size == 0
    prev.each do |loc|
      total_qty += loc.quantity
    end
    return do_error(I18n.t('receipt_location.reversal_qty_too_big')) if self.quantity + total_qty < 0
    true
  end

  def do_error (message)
    self.errors[:base] << message
    throw :abort
  end



end
