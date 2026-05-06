# frozen_string_literal: true

class ReceiptUploadDtlsController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :ensure_minimum_filter
  before_action :get_receipt_upload

  def index
    if params[:runmode] && %w(consume).include?(params[:runmode])
      @runmode = params[:runmode]
    else
      @runmode = 'upload'
    end
    @receipt_upload_dtls = ReceiptUploadDtl.using('tbdash').for_hdr(@receipt_upload_hdr.id)
    current_size = userset_page_size('receipt_upload_details')
    @receipt_upload_dtls = @receipt_upload_dtls.ordered.page(params[:page]).per(current_size)
  end

  private
  
  def get_receipt_upload
    if params[:id]
      @receipt_upload_hdr = ReceiptUploadHdr.using('tbdash').find(params[:id].to_i)
    else
      @receipt_upload_hdr = ReceiptUploadHdr.using('tbdash').find(params[:receipt_upload_hdr_id].to_i)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to receipt_upload_hdrs_path, alert: t('receipt_upload_hdr.not_found')
  end

end
