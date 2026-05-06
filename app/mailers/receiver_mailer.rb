class ReceiverMailer < ActionMailer::Base
  REPLY_TO = ENV['MAIL_USERNAME'] || "thoroughbred.dashboard@gmail.com"
  default from: REPLY_TO

  def receiver(client_id, receipt_batch_id)
    # puts "***************** ReceiverMailer"
    client = Client.using('pg').find(client_id)
    @receipt_batch = ReceiptBatch.using('pg').find(receipt_batch_id)
    @receipt_items = @receipt_batch.receipt_items
    empnos = @receipt_batch.receipt_items.pluck(:empno).uniq
    cc = ""
    empnos.each do |empno|
      user = User.where(empno: empno).first
      if user
        cc += ', ' unless cc == ""
        cc += user.email
      end
    end
    @batch_title = begin
      vendor = TbdashVendor.using(client.cust_no).where(vendor_no: @receipt_batch.vendor_no).first if @receipt_batch.vendor_no
      vendor_title = vendor ? ' for ' + vendor.vendor_no + ' - ' + vendor.vendor_name : @receipt_batch.vendor_no
      @receipt_batch.id.to_s + ' ' + @receipt_batch.note + vendor_title
    end
    tracking_ref = @receipt_batch.tracking_ref.nil? ? ' '  : @receipt_batch.tracking_ref
    mail(to: client.client_manager_email,
         cc: cc,
         subject: I18n.t('mailer.receiver', batch: @receipt_batch.id.to_s + ' ' + tracking_ref))
  end

end