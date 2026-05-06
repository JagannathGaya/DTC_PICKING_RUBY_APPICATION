# frozen_string_literal: true

class ReceiptUploadHdrsController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :ensure_minimum_filter
  before_action :get_receipt_upload, only: [:destroy, :edit, :update]
  before_action :get_vendors, only: [:new, :create, :edit, :editerr, :update]

  def index
    @vendors = TbdashVendor.using(@current_client.cust_no).all.ordered.map { |r| [r.vendor_no + '-' + r.vendor_name, r.vendor_no] }
    if params[:mode] && %w(consume view).include?(params[:mode])
      @runmode = params[:mode]
    else
      @runmode = 'upload'
    end
    current_size = userset_page_size('receipt_upload_hdrs')
    @receipt_upload_hdrs = ReceiptUploadHdr.using('tbdash')
                                           .for_client_db(@current_client.username)
                                           .using('tbdash')
                                           .includes(:receipt_upload_dtls)
    session[:filter]['receipt_upload_status_filter'] = 'Open' if %w(consume view).include?(@runmode)
    session[:filter]['receipt_upload_status_filter'] ||= 'Not Complete'
    if filter('receipt_upload_status_filter') == 'Not Complete'
      @receipt_upload_hdrs = @receipt_upload_hdrs.where("upload_status != 'Complete'")
    else
      @receipt_upload_hdrs = @receipt_upload_hdrs.filter_by_column(:upload_status,
                                                                   filter('receipt_upload_status_filter'), t(:all))
    end
    @receipt_upload_hdrs = @receipt_upload_hdrs.filter_column_contains(:po_ref, filter('receipt_upload_po_ref_filter'))
                                               .filter_by_column(:vendor_no, filter('receipt_upload_vendor_filter'), t(:all))
                                               .filter_by_column(:delivery_type, filter('receipt_upload_delivery_type_filter'), t(:all))
                                               .filter_pg_date_range(:dt_expected, filter('rudt_expected_date1_filter'),
                                                                     filter('rudt_expected_date2_filter'))
                                               .ordered.page(params[:page]).per(current_size)
  end

  def new
    @receipt_upload_hdr = ReceiptUploadHdr.using('tbdash').new
    @receipt_upload_hdr.client = @current_client
    @receipt_upload_hdr.upload_status = 'Open'
    render layout: false
  end

  def create
    @receipt_upload_hdr = ReceiptUploadHdr.using('tbdash').new(receipt_upload_hdr_params)
    @receipt_upload_hdr.filename = params[:receipt_upload_hdr][:filename].original_filename if params[:receipt_upload_hdr][:filename]
    tbdash_client = Client.using('tbdash').where(username: @current_client.username).first
    @receipt_upload_hdr.client_id = tbdash_client.id
    if @receipt_upload_hdr.save
      resp = ReceiptUploadService.new(@receipt_upload_hdr, @current_client).load_detail(params[:receipt_upload_hdr][:filename].path) if params[:receipt_upload_hdr][:filename]
      if @receipt_upload_hdr.notes?
        flash[:alert] = t('receipt_upload_hdr.created_with_notes')
      else
        flash[:notice] = t('receipt_upload_hdr.created')
      end
      redirect_to receipt_upload_hdrs_path
    else
      flash[:alert] = t('receipt_upload_hdr.not_created')
      render action: :new
    end
  end

  def edit
    render layout: false
  end

  def update
    if @receipt_upload_hdr.update(receipt_upload_hdr_params)
      redirect_to receipt_upload_hdrs_path, notice: t('receipt_upload_hdr.updated')
    else
      flash[:alert] = t('receipt_upload_hdr.not_updated')
      render action: :editerr
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to receipt_upload_hdrs_path, alert: t('receipt_upload_hdr.conflict')
  end

  def editerr
  end

  def destroy
    @receipt_upload_hdr.destroy
    if @receipt_upload_hdr.errors.count == 0
      flash[:notice] = t('receipt_upload_hdr.deleted')
    else
      flash[:alert] = t('receipt_upload_hdr.not_deleted') + ' ' + @receipt_upload_hdr.errors.full_messages.flatten.join(' ')
    end
    redirect_to receipt_upload_hdrs_path
  rescue ActiveRecord::StaleObjectError
    redirect_to receipt_upload_hdrs_path, alert: t('receipt_upload_hdr.conflict')
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

  def receipt_upload_hdr_params
    params.require(:receipt_upload_hdr).permit(:client_id, :note, :upload_status, :lock_version, :tracking_ref,
                                               :po_ref, :vendor_no, :delivery_type, :dt_expected, :hr_expected,
                                               :filename, :boxcount)
  end

  def get_vendors
    @tbdash_vendors = TbdashVendor.using(@current_client.cust_no).ordered
  end

end
