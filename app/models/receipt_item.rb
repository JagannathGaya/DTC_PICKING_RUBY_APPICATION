class ReceiptItem < ApplicationRecord
  include CommonUtils

  scope :ordered, -> {order(:receipt_batch_id).order(id: :desc)}
  scope :for_batch, -> (receipt_batch_id) {where(receipt_batch_id: receipt_batch_id)}
  scope :check_dup, -> (receipt_batch_id, item_no) {where(receipt_batch_id: receipt_batch_id, item_no: item_no)}

  belongs_to :receipt_batch
  has_many :receipt_locations, dependent: :delete_all

  before_save :upcase_fields
  before_save :check_item
  before_save :check_dup
  before_update :check_item_change
  after_create :set_batch_status

  def qty_remaining
    self.quantity - self.receipt_locations.sum(:quantity)
  end

  def to_btxml(copies)
    tbdash_item = get_item
    client = self.receipt_batch.client.cust_no
    client_name = self.receipt_batch.client.cust_name
    format_file = Rails.application.config.label_format[:receiving]
    printer = Rails.application.config.label_printer[:receiving]
    receipt_date = formatted_date(self.receipt_batch.dock_receipt_at)
    content = btxml_wrap("client_id", client) +
        btxml_wrap("client_name", client_name) +
        btxml_wrap("receipt_date", receipt_date) +
        btxml_wrap("item_no", self.item_no) +
        btxml_wrap("description", tbdash_item.description)

    '<?xml version="1.0" encoding="utf-8"?>' + "\r\n" +
        '<XMLScript Version="2.0">' + "\r\n" +
        "  <Command>\r\n" +
        "    <Print>\r\n" +
        "      <Format>#{format_file}</Format>\r\n" +
        "      <PrintSetup>\r\n" +
        "        <Printer>#{printer}</Printer>\r\n" +
        "        <IdenticalCopiesOfLabel>#{copies}</IdenticalCopiesOfLabel>\r\n" +
        "      </PrintSetup>\r\n" +
        content +
        "    </Print>\r\n" +
        "  </Command>\r\n" +
        "</XMLScript>\r\n"
  end

  def to_csv(copies)
    tbdash_item = get_item
    client = "#{self.receipt_batch.client.cust_no}"
    client_name = "#{self.receipt_batch.client.cust_name}"
    receipt_date = "#{formatted_date(self.receipt_batch.dock_receipt_at, :label)}"
    item_no = "\"#{self.item_no}\""
    description = "\"#{tbdash_item.description}\""

    format_file = Rails.application.config.label_format[:receiving]
    printer = Rails.application.config.label_printer[:receiving]
    kolumn_data = [client, client_name, receipt_date, item_no, description]
    csv = ""
    csv << "%BTW% /AF=\"#{format_file}\" /D=\"%Trigger File Name%\" /PRN=\"#{printer}\" /R=3 /C=#{copies} /P /DD" + "\n"
    csv << "%END%" + "\n"
    csv << kolumn_data.join(',') + "\n"
    csv
  end

  def to_861
    [self.item_no, self.qty_shipped, self.quantity, self.vendor_id, self.po_no, self.shipment_no, self.shipment_date, self.shipment_line].to_csv
    # ITEM_NO,QTY_SHIPPED,QTY_RCVD,VENDOR,PO_NUM,SHIPMENT,ASN_DATE,LINE_NO
  end

#   %BTW% /AF="L:\production\Nas24\carton1pack.btw" /D="%Trigger File Name%" /PRN="IS HP 8100N" /R=3 /C=1 /P /DD
#   %END%
# 4500C102,2,"6-wheel tender trucks",4500,,2,100004500,,,4500X102,United States,4500X103,United States,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,United States,2,,2,"","","","","","",,"",,

  def valid_item?
    self.description != '* Invalid Item'
  end

  def current_default_loc
    get_item&.current_default_loc
  end

  private

  def upcase_fields
    self.item_no.upcase! if self.item_no
    self.boxcount ||= 0
    self.quantity ||= 0
  end

  def set_batch_status
    self.receipt_batch.reload
    self.receipt_batch.batch_status = 'Open' unless self.receipt_batch.batch_status == 'Open'
    self.receipt_batch.save
  end

  def get_item
    TbdashSimpleItem.using(receipt_batch.client.cust_no).where(item_no: self.item_no).first
  end

  def check_item
    # puts "CHECKING #{receipt_batch.client.cust_no} #{self.item_no}"
    tbdash_item = get_item
    if tbdash_item
      # puts "\n#{tbdash_item.item_no}  #{tbdash_item.status_flag}  #{tbdash_item.discontinue_flag}"
      self.note = "#{self.note.to_s}Inactive;" if tbdash_item.status_flag == 'Inactive' && (!self.note || (self.note && self.note.index('Inactive;').nil?))
      self.note = "#{self.note.to_s}Discontinued;" if tbdash_item.discontinue_flag == 'Yes' && (!self.note || (self.note && self.note.index('Discontinued;').nil?))
      self.status_flag = true if tbdash_item.status_flag == 'Active'
      self.discontinue_flag = true if tbdash_item.discontinue_flag == 'Yes'
      self.description = tbdash_item.description
    else
      self.searched = true
      self.description = '* Invalid Item'
    end
  end

  def check_dup
    others = ReceiptItem.check_dup(self.receipt_batch_id, self.item_no)
    others.each do |them|
      if self.id.nil? || self.id != them.id
        return do_error(I18n.t('receipt_item.duplicate_item'))
      end
    end
    true
  end

  def check_item_change
    if self.changed_attributes["item_no"] && self.changed_attributes["item_no"] != self.item_no
      if self.receipt_locations.size > 0
        return do_error(I18n.t('receipt_item.locations_exist'))
      end
    end
    true
  end

  def do_error(message)
    self.errors[:base] << message
    throw :abort
  end

end
