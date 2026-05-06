module ReceiptHelper

  def edit_receipt_batch_link(receipt_batch)
    return unless receipt_batch
    # return unless receipt_batch.can_be_edited?
    link_to edit_receipt_batch_path(receipt_batch), class: 'btn btn-sm btn-primary', data: {colorbox: true, colorbox_width: 800, colorbox_height: 600} do
      icon('edit') + t('receipt_batch.edit')
    end
  end

  def list_receipt_batch_lines_link(receipt_batch)
    return unless receipt_batch
    return unless receipt_batch.can_details_be_edited?
    link_to new_receipt_batch_receipt_item_path(receipt_batch), class: 'btn btn-sm btn-primary' do
      icon('edit') + t('receipt_batch.edit_lines')
    end
  end

  def new_receipt_batch_link
    link_to new_receipt_batch_path, class: 'btn btn-sm btn-primary', data: {colorbox: true, colorbox_width: 800, colorbox_height: 600} do
      icon('plus') + t('receipt_batch.new')
    end
  end

  def view_uploads_link
    link_to receipt_upload_hdrs_path(params: { mode: "view"}), class: 'btn btn-sm btn-primary' do
      icon('upload') + t('receipt_batch.view_uploads')
    end
  end

  def new_batch_from_upload_link
    link_to receipt_upload_hdrs_path(params: { mode: "consume"}), class: 'btn btn-sm btn-primary' do
      icon('upload') + t('receipt_batch.new_from_upload')
    end
  end

  def delete_receipt_batch_link(receipt_batch)
    return unless receipt_batch
    return unless receipt_batch.can_be_deleted?
    link_to receipt_batch_path(receipt_batch), method: :delete, data: {confirm: t('receipt_batch.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') + t('receipt_batch.delete')
    end
  end

  def list_receipt_batches_link
    link_to receipt_batches_path, class: 'btn btn-sm btn-primary' do
      icon('list') + t('receipt_batch.list_all')
    end
  end

  def close_receipt_batch_link(receipt_batch)
    return unless receipt_batch.can_be_edited?
    link_to receipt_batch_close_path(receipt_batch), method: :put, class: 'btn btn-sm btn-primary' do
      icon('times') + t('receipt_batch.close')
    end
  end

  def receipt_batch_download_861_link(receipt_batch)
    return unless receipt_batch&.complete?
    link_to receipt_batch_download_861_path(receipt_batch), class: 'btn btn-sm btn-primary' do
      icon('download') + t('receipt_batch.download_861')
    end
  end

  def receipt_batch_status_filter
    statuses = ReceiptBatch::BATCH_STATUSES.clone
    select_tag 'receipt_batch_status_filter', options_for_select(statuses.unshift('Not Complete').unshift(t(:all)), session[:filter]['receipt_batch_status_filter'])
  end

  def receipt_batch_vendor_filter
    select_tag 'receipt_batch_vendor_filter', options_for_select(@vendors.unshift(t(:all)), session[:filter]['receipt_batch_vendor_filter'])
  end


  def find_receipt_item_link(receipt_batch, receipt_item)
    # puts " receipt_item.inspect #{receipt_item.inspect}"
    link_to receipt_batch_find_item_path(receipt_batch, params: {xxxx: receipt_item.inspect, receipt_item_no: receipt_item.item_no || '%', receipt_item_id: receipt_item.id}), class: 'btn btn-sm btn-primary' do
      icon('search') + t('receipt_item.find_item')
    end
  end

  def new_receipt_item_link(receipt_batch)
    return unless receipt_batch
    link_to new_receipt_batch_receipt_item_path(receipt_batch), class: 'btn btn-sm btn-primary' do
      icon('plus') + t('receipt_item.new')
    end
  end

  def edit_receipt_item_link(receipt_item)
    return unless receipt_item
    return unless receipt_item.receipt_batch.can_be_edited?
    link_to edit_receipt_batch_receipt_item_path(receipt_item.receipt_batch_id, receipt_item) do
      receipt_item.item_no
    end

  end

  def delete_receipt_item_link(receipt_item)
    return unless receipt_item
    return unless receipt_item.receipt_batch.can_be_edited?
    return unless receipt_item.qty_remaining == receipt_item.quantity
    link_to receipt_batch_receipt_item_path(receipt_item.receipt_batch_id, receipt_item), method: :delete, data: {confirm: t('receipt_item.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') # + t('receipt_item.delete')
    end
  end

  def edit_receipt_item_label_link(receipt_item)
    return unless receipt_item
    link_to receipt_batch_receipt_item_edit_label_path(receipt_item.receipt_batch_id, receipt_item),
            class: 'btn btn-sm btn-primary',
            data: {colorbox: true, colorbox_width: 600, colorbox_height: 300} do
      icon('print') # +  t('receipt_item.print_label')
    end
  end

  def putaway_receipt_item_label_link(receipt_item)
    return unless receipt_item
    link_to receipt_batch_receipt_item_putaway_label_path(receipt_item.receipt_batch_id, receipt_item),
            class: 'btn btn-sm btn-primary',
            data: {colorbox: true, colorbox_width: 600, colorbox_height: 300} do
      icon('print')
    end
  end

  def search_select_receipt_item(item, receipt_item, receipt_batch)
    return unless item
    # puts "*********** #{@receipt_batch.inspect} #{receipt_item.inspect} #{item.inspect}"
    link_to receipt_batch_receipt_item_found_item_path(receipt_batch.id, receipt_item.id,
                                                       params: {item_id: item.id}), method: :put, class: 'btn btn-sm btn-primary' do
      icon('ok-circle') + t('select')
    end
  end

  # def send_to_oracle_link(receipt_batch)
  #   return unless receipt_batch
  #   return unless receipt_batch.can_be_posted?
  #   link_to receipt_batch_send_to_oracle_path(receipt_batch), class: 'btn btn-sm btn-primary' do
  #     icon('play') + t('receipt_batch.post')
  #   end
  # end

  def putaway_link(receipt_batch)
    return unless receipt_batch
    return unless receipt_batch.can_be_putaway?
    link_to receipt_batch_start_putaway_path(receipt_batch), method: :put, class: 'btn btn-sm btn-primary' do
      icon('play') + t('receipt_batch.putaway')
    end
  end

  def list_detail_link(receipt_batch)
    link_to receipt_locations_path(params: {receipt_batch_id: receipt_batch.id}), class: 'btn btn-sm btn-primary' do
      icon('th-list') + t('receipt_location.list')
    end
  end

  def mute_all_receipts_link(receipt_batch)
    link_to receipt_batch_mute_all_path(receipt_batch.id),
            method: :put, data: {confirm: t('receipt_item.confirm_mute_all')}, class: 'btn btn-sm btn-primary' do
      icon('eye-slash')
    end
  end

  def unmute_all_receipts_link(receipt_batch)
    link_to receipt_batch_unmute_all_path(receipt_batch.id),
            method: :put, class: 'btn btn-sm btn-danger' do
      icon('eye')
    end
  end

  def mute_receipt_item_link(receipt_item)
    if receipt_item.mute
      link_to receipt_batch_receipt_item_mute_path(receipt_item.receipt_batch_id, receipt_item),
              method: :put, class: 'btn btn-sm btn-danger' do
        icon('ok-circle') + t('receipt_item.unmute')
      end
    else
      link_to receipt_batch_receipt_item_mute_path(receipt_item.receipt_batch_id, receipt_item),
              method: :put, class: 'btn btn-sm btn-primary' do
        icon('ok-circle') + t('receipt_item.mute')
      end
    end
  end

  def select_item_default_link(receipt_item)
    link_to receipt_batch_receipt_item_select_default_path(receipt_item.receipt_batch_id, receipt_item),
            method: :put, class: 'btn btn-sm btn-success' do
      icon('ok-circle') + t('receipt_item.select_default')
    end unless receipt_item.mute || receipt_item.qty_remaining == 0
  end

  def select_putaway_location(tbdash_recv_putaway_loc, receipt_batch)
    link_to new_receipt_location_path(params: {receipt_item_no: tbdash_recv_putaway_loc.item_no,
                                               stock_area: tbdash_recv_putaway_loc.stock_area,
                                               bin_loc: tbdash_recv_putaway_loc.bin_loc,
                                               loc_type: tbdash_recv_putaway_loc.loc_type,
                                               receipt_batch_id: receipt_batch.id}), class: 'btn btn-sm btn-primary' do
      icon('plus') + t('receipt_location.select_putaway_location')
    end
  end

  def batch_title(receipt_batch)
    vendor = TbdashVendor.using(@current_client.cust_no).where(vendor_no: receipt_batch.vendor_no).first if receipt_batch.vendor_no
    vendor_title = vendor ? ' for ' + vendor.vendor_no + ' - ' + vendor.vendor_name : receipt_batch.vendor_no
    receipt_batch.id.to_s + ' ' + receipt_batch.note + vendor_title
  end

  def putaway_loc_color(tbdash_recv_putaway_loc)
    return case tbdash_recv_putaway_loc.loc_type
             when 'DEFAULT'
               tbdash_recv_putaway_loc.sku_count > 1 ? 'color: red;' : ' '
             when 'EXISTING'
               tbdash_recv_putaway_loc.sku_count > 1 ? 'color: magenta;' : ' '
             when 'EMPTY'
               ' '
             else
               ' '
           end
  end

  def create_batch_from_receipt_upload_hdr_link(receipt_upload_hdr)
    return unless receipt_upload_hdr
    link_to from_upload_receipt_batches_path(params: { upload_batch: receipt_upload_hdr.id}), method: :put, class: 'btn btn-sm btn-primary' do
      icon('transfer') + t('select')
    end
  end

  def extended_status(receipt_item)
    return 'Active' if receipt_item.status_flag  && !receipt_item.discontinue_flag
    return "<span class='redlight'>Inactive</span>".html_safe if !receipt_item.status_flag && !receipt_item.discontinue_flag
    return "Active<br/><span class='redlight'>discontinued</span>".html_safe if receipt_item.status_flag  && receipt_item.discontinue_flag
    return "<span class='redlight'>Inactive<br/>discontinued</span>".html_safe if !receipt_item.status_flag && receipt_item.discontinue_flag
  end

  def display_description(description)
    return description == '* Invalid Item' ? "<span class='redlight'>#{description}</span>".html_safe : description
  end

end