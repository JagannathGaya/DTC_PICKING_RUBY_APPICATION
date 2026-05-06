class ReceiptUploadDtl < ApplicationRecord

  scope :ordered, -> {order(:line_no)}
  scope :for_hdr, -> (receipt_upload_hdr_id) {where(receipt_upload_hdr_id: receipt_upload_hdr_id)}

  belongs_to :receipt_upload_hdr

  validates :item_no, presence: true, length: {maximum: 30}
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  before_save :upcase_fields

  def can_be_used?
    ['Open'].include?(self.batch_status)
  end

  private

  def upcase_fields
    self.item_no.upcase! if self.item_no
  end

end
