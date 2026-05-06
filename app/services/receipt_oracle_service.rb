class ReceiptOracleService

  def initialize(receipt_location, client)
    @receipt_location = receipt_location
#    puts "*** #{@receipt_location.inspect}"
    @receipt_item = @receipt_location.using('pg').receipt_item
#    puts "*** #{@receipt_item.inspect}"
    @receipt_batch = @receipt_item ? @receipt_location.using('pg').receipt_item.receipt_batch : nil
    @client = client
  end

  def send_to_oracle
    @receipt_location.fast_reference = TbdashFastReference.using(@client.cust_no).first.fast_reference.to_i.to_s
    @receipt_location.save
    FastReceipt.transaction do
      begin
        fast_receipt = FastReceipt.using(@client.cust_no).new(
            item_no: @receipt_item.item_no,
            trans_date: @receipt_location.created_at,
            trans_qty: @receipt_location.quantity,
            stock_area: @receipt_location.stock_area,
            bin_loc: @receipt_location.bin_loc,
            empno: @receipt_item.empno,
            fast_reference: @receipt_location.fast_reference,
            auto_voucher_flag: 'N',
            plant_code: '10',
            unit_code: '100',
            buyer_code: nil,
            control_no: nil,
            control_no_end: nil,
            date_expires: nil,
            init: nil,
            reason_code: nil,
            ref_remark: @receipt_item.vendor_id.blank? && @receipt_item.po_no.blank? && @receipt_item.comment ? @receipt_item.comment[0..49] : "#{@receipt_item.vendor_id} / #{@receipt_item.po_no}",
            set_def_loc: @receipt_location.new_default ? 'Y' : 'N',
            vendor_id: @receipt_batch.vendor_no,
            vendor_inv_amt: nil,
            vendor_inv_date: nil,
            vendor_inv_no: nil,
            nds_version_no: nil,
            make_item_active: @receipt_item.status_flag ? 'N' : 'Y')
        # puts "FastReceipt = #{fast_receipt.inspect}"
        fast_receipt.save
        return false
      rescue ActiveRecord::ActiveRecordError => e
        puts "ReceiptOracleService FAILED error = #{e.inspect}"
        @receipt_item.note = get_error_string(e)
        @receipt_item.save
        raise ActiveRecord::Rollback
      end
    end
    return @receipt_item.note

  end

  def get_error_string(e)
    e.to_s.split('ORA-2')[1].split('ORA-')[0][6..99] rescue ' '
  end

end

