class ReceiptUploadHdr < ApplicationRecord

  scope :ordered, -> {order(created_at: :desc).order(:id)}
  scope :for_client, -> (client_id) {where(client_id: client_id)}
  scope :for_client_db, -> (username) {where("client_id in (select id from clients where clients.username = ?)", username)}

  belongs_to :client
  has_many :receipt_upload_dtls, dependent: :delete_all

  UPLOAD_STATUSES = ['Open', 'Complete', 'Uploaded']
  validates :upload_status, inclusion: {in: UPLOAD_STATUSES.map(&:to_s), allow_blank: false}
  validates :po_ref, presence: true, length: {maximum: 30}
  validates :tracking_ref, length: {maximum: 50}
  validates :vendor_no, presence: true, length: {maximum: 10}
  DELIVERY_TYPES = %w(UPS Fedex LTL Other Unknown)
  validates :delivery_type, inclusion: {in: DELIVERY_TYPES.map(&:to_s), allow_blank: false}
  validates :hr_expected, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 24 }
  validates :boxcount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }


  before_create :set_initial_statuses
  before_save :upcase_fields

  def can_be_used?
    ['Open'].include?(self.batch_status)
  end

  def notes?
    self.receipt_upload_dtls.where("note <> ''").first ? true : false
  end

  def actual_boxcount
    self.receipt_upload_dtls.sum(:boxcount)
  end

  private

  def upcase_fields
    self.po_ref.upcase! if self.po_ref
    self.tracking_ref.upcase! if self.tracking_ref
    self.vendor_no.upcase! if self.vendor_no
  end

  def set_initial_statuses
    self.upload_status ||= 'Open'
    self.delivery_type ||= 'Unknown'
  end


end
