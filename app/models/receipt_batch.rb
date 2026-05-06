class ReceiptBatch < ApplicationRecord

  scope :ordered, -> {order(created_at: :desc).order(:id)}
  scope :for_client, -> (client_id) {where(client_id: client_id)}

  belongs_to :client
  has_many :receipt_items, dependent: :delete_all
  has_many :receipt_locations, through: :receipt_items

  INCOMPLETE = 'Incomplete'
  OPEN = 'Open'
  PENDING = 'Pending'
  COMPLETE = 'Complete'
  BATCH_STATUSES = [INCOMPLETE, OPEN, PENDING, COMPLETE]
  validates :batch_status, inclusion: {in: BATCH_STATUSES.map(&:to_s), allow_blank: false}
  validates :vendor_no, presence: true, length: {maximum: 10}
  validates :po_ref, length: {maximum: 30}
  validates :tracking_ref, length: {maximum: 50}

  after_validation :check_status
  before_create :set_initial_batch_status
  before_save :upcase_fields
  after_save :complete_upload

  def can_be_posted?
    [PENDING].include?(self.batch_status)
  end

  def can_details_be_edited?
    [INCOMPLETE, OPEN].include?(self.batch_status)
  end

  def can_be_edited?
    [INCOMPLETE, OPEN, PENDING].include?(self.batch_status)
  end

  def can_be_putaway?
    [OPEN].include?(self.batch_status)
  end

  def can_be_deleted?
    [INCOMPLETE, COMPLETE].include?(self.batch_status)
  end

  def complete?
    self.batch_status == COMPLETE
  end

  def empno_inits(connection)
    employee = TbdashEmployee.using(connection).where(empno: self.empno).first
    employee ? employee.initials : nil
  end

  def to_861
    rows = ""
    rows << ['ITEM_NO','QTY_SHIPPED','QTY_RCVD','VENDOR','PO_NUM','SHIPMENT','ASN_DATE','LINE_NO'].to_csv
    self.receipt_items.ordered.each {|line| rows << line.to_861}
    rows
  end

  private

  def upcase_fields
    self.tracking_ref.upcase! if self.tracking_ref
    self.empno.upcase! if self.empno
  end

  def set_initial_batch_status
    self.batch_status = 'Incomplete'
  end

  def check_status
    if self.batch_status == 'Pending'
      qty_remaining_total = self.using('pg').receipt_items.using('pg').includes(:receipt_locations).inject(0) {|sum, e| sum + e.qty_remaining}
      if qty_remaining_total != 0
        self.errors[:base] << I18n.t('receipt_batch.status_error_pending')
        throw :abort
      end
    end
  end

  def complete_upload
    if self.receipt_upload_hdr_id
      if self.batch_status_changed? && self.batch_status == 'Complete'
        upload = ReceiptUploadHdr.using('tbdash').find_by(id: self.receipt_upload_hdr_id)
        if upload
          upload.upload_status = 'Complete'
          upload.save!
        end
      end
    end
  end


end
