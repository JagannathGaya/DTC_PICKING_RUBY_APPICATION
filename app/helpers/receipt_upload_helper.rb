# frozen_string_literal: true

module ReceiptUploadHelper

  def edit_receipt_upload_hdr_link(receipt_upload_hdr)
    return unless receipt_upload_hdr
    return if receipt_upload_hdr.upload_status == 'Complete'
    link_to edit_receipt_upload_hdr_path(receipt_upload_hdr),
            class: 'btn btn-sm btn-primary',
            data: {colorbox: true, colorbox_width: 800, colorbox_height: 750} do
      icon('plus') + t('receipt_upload_hdr.edit')
    end
  end

  def new_receipt_upload_hdr_link
    link_to new_receipt_upload_hdr_path,
            class: 'btn btn-sm btn-primary',
            data: {colorbox: true, colorbox_width: 800, colorbox_height: 750} do
      icon('plus') + t('receipt_upload_hdr.new')
    end
  end

  def delete_receipt_upload_hdr_link(receipt_upload_hdr)
    return unless receipt_upload_hdr
    link_to receipt_upload_hdr_path(receipt_upload_hdr),
            method: :delete,
            data: {confirm: t('receipt_upload_hdr.confirm_delete')},
            class: 'btn btn-sm btn-primary' do
      icon('trash') + t('receipt_upload_hdr.delete')
    end
  end

  def list_receipt_upload_hdrs_link(runmode)
    link_to receipt_upload_hdrs_path(params: {mode: runmode}), class: 'btn btn-sm btn-primary' do
      icon('list') + t('receipt_upload_hdr.list_all')
    end
  end

  def receipt_upload_status_filter
    statuses = ReceiptUploadHdr::UPLOAD_STATUSES.clone
    select_tag 'receipt_upload_status_filter',
               options_for_select(statuses.unshift('Not Complete').unshift(t(:all)), session[:filter]['receipt_upload_status_filter'])
  end

  def view_receipt_upload_hdr_link(receipt_upload_hdr, runmode = 'upload')
    return unless receipt_upload_hdr
    link_to receipt_upload_hdr_receipt_upload_dtls_path(receipt_upload_hdr, params: {runmode: runmode}),
            class: 'btn btn-sm btn-primary' do
      icon('binoculars') + t('receipt_upload_hdr.view')
    end
  end

  def receipt_upload_vendor_filter
    select_tag 'receipt_upload_vendor_filter',
               options_for_select(@vendors.unshift(t(:all)), session[:filter]['receipt_upload_vendor_filter'])
  end

  def receipt_upload_delivery_type_filter
    delivery_types = ReceiptUploadHdr::DELIVERY_TYPES.clone
    select_tag 'receipt_upload_delivery_type_filter',
               options_for_select(delivery_types.unshift(t(:all)), session[:filter]['receipt_upload_delivery_type_filter'])
  end

end