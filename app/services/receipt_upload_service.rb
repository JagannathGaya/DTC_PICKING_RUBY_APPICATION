class ReceiptUploadService

  def initialize(receipt_upload_hdr, client)
    @receipt_upload_hdr = receipt_upload_hdr
    @client = client
  end

  def load_detail(filename)
    items = []
    count = 0
    # puts "ReceiptUploadService filename #{filename.inspect}"

    CSV.foreach(filename, headers: true, skip_blanks: true) do |row|
      count += 1
      @note = validate_row(row.to_h.values, count)
      next if row[0].blank? && row[1].blank? # no item or qty = ignore
      ix = items.find_index { |item| @item_no == item.item_no }
      if ix
        items[ix].quantity += @quantity
        items[ix].boxcount += @boxcount
      else
        items << ReceiptUploadDtl.using('tbdash').new(receipt_upload_hdr_id: @receipt_upload_hdr.id,
                                                      line_no: count,
                                                      item_no: @item_no,
                                                      quantity: @quantity,
                                                      boxcount: @boxcount,
                                                      note: @note.lstrip,
                                                      vendor_id: @vendor_id,
                                                      po_no: @po_no,
                                                      shipment_no: @shipment_no,
                                                      shipment_line: @shipment_line,
                                                      shipment_date: @shipment_date,
                                                      qty_shipped: @qty_shipped)
      end
    end
    resp = ReceiptUploadDtl.using('tbdash').import(items, validate: true)
  end

  private

  def validate_row(row, count)
    # row is now an array with five values: item, qty, boxes, vendor_id, po_no
    # strip leading and trailing blanks and special chars
    #
    note = ' '
    return note if row[0].blank? && row[1].blank?
    @item_no = row[0]
    @item_no ||= '** MISSING **'
    @item_no = @item_no.upcase.strip
    tb_item = TbdashSimpleItem.using(@client.cust_no).where(item_no: @item_no).first
    note += "Item number is not valid; " unless tb_item
    if @item_no&.length > 30
      note += "Item number truncated from #{@item_no}; "
      @item_no = @item_no[0, 30]
    end
    if row[1].strip =~ /\A\d+\z/
      @quantity = row[1].strip.to_i
    else
      @quantity = 1
      note += "Quantity #{row[1]} replaced by one; "
    end
    if row[2].blank?
      @boxcount = 0
    elsif row[2].strip =~ /\A\d+\z/
      @boxcount = row[2].strip.to_i
    else
      @boxcount = 1
      note += "Box count #{row[2]} replaced by one; "
    end
    if row.size > 3
      @vendor_id = row[3]
      if @vendor_id&.length > 15
        note += "Vendor ID truncated from #{@vendor_id}; "
        @vendor_id = @vendor_no[0, 15]
      end
    else
      @vendor_id = nil
    end
    if row.size > 4
      @po_no = row[4]
      if @po_no&.length > 12
        note += "PO Number truncated from #{@po_no}; "
        @po_no = @po_no[0, 12]
      end
    else
      @po_no = nil
    end
    if row.size > 5
      @shipment_no = row[5]
    else
      @shipment_no = nil
    end
    if row.size > 6
      @shipment_line = row[6]
    else
      @shipment_line = nil
    end
    if row.size > 7
      @shipment_date = row[7]
    else
      @shipment_line = nil
    end
    if row.size > 8
      @qty_shipped = row[8]
    else
      @qty_shipped = nil
    end
    note
  end

end