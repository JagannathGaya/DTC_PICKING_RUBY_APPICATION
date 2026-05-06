class ReceiverCommentMailer < ActionMailer::Base
  REPLY_TO = ENV['MAIL_USERNAME'] || "thoroughbred.dashboard@gmail.com"
  default from: REPLY_TO

  def send_comment(client_id, receipt_batch_id, receipt_item_id, comment_text)
    puts "***************** ReceiverCommentMailer"
    @client = Client.using('pg').find(client_id)
    @receipt_batch = ReceiptBatch.using('pg').find(receipt_batch_id)
    @receipt_item = ReceiptItem.using('pg').find(receipt_item_id)
    @comment_text = comment_text
    empnos = @receipt_batch.receipt_items.pluck(:empno).uniq
    cc = ""
    empnos.each do |empno|
      user = User.where(empno: empno).first
      cc += user.email + ', '
    end
    @batch_title = begin
      vendor = TbdashVendor.using(@client.cust_no).where(vendor_no: @receipt_batch.vendor_no).first if @receipt_batch.vendor_no
      vendor_title = vendor ? ' for ' + vendor.vendor_no + ' - ' + vendor.vendor_name : @receipt_batch.vendor_no
      @receipt_batch.id.to_s + ' ' + @receipt_batch.note + vendor_title
    end
    tracking_ref = @receipt_batch.tracking_ref.nil? ? ' '  : @receipt_batch.tracking_ref
    mail(to: @client.client_manager_email,
         cc: cc,
         subject: I18n.t('receipt_item.mail_tbrc_title',
                         batch: @receipt_batch.id.to_s + ' ' + tracking_ref,
                         item: @receipt_item.item_no))
  end

end