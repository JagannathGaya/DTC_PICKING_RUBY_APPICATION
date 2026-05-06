class ReceiptBatchesController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :ensure_minimum_filter
  before_action :get_receipt_batch, only: [:destroy, :edit, :update, :send_to_oracle, :find_item, :putaway, :start_putaway, :close, :mute_all, :unmute_all, :download_861]
  before_action :get_vendors, only: [:new, :create, :edit, :editerr, :update]

  def index
    @receiving_note = TbdashClientGlobal.receiving_note(@current_client.cust_no)
    @vendors = TbdashVendor.using(@current_client.cust_no).all.ordered.map { |r| [r.vendor_no + '-' + r.vendor_name, r.vendor_no] }
    current_size = userset_page_size('receipt_batches')
    @receipt_batches = ReceiptBatch.using('pg').for_client(@current_client.id)
    session[:filter]['receipt_batch_status_filter'] ||= 'Not Complete'
    if filter('receipt_batch_status_filter') == 'Not Complete'
      @receipt_batches = @receipt_batches.where("batch_status != 'Complete'")
    else
      @receipt_batches = @receipt_batches.filter_by_column(:batch_status, filter('receipt_batch_status_filter'), t(:all))
    end
    @receipt_batches = @receipt_batches.filter_column_contains(:po_ref, filter('receipt_batch_po_ref_filter'))
                           .filter_by_column(:vendor_no, filter('receipt_batch_vendor_filter'), t(:all))
                           .ordered.page(params[:page]).per(current_size)
  end

  def new
    @receipt_batch = ReceiptBatch.using('pg').new
    @receipt_batch.client = @current_client
    @receipt_batch.batch_status = 'Incomplete'
    @receipt_batch.dock_receipt_at = Time.zone.now - 2.hours - (Time.zone.now.to_i % 60.minutes)
    @receipt_batch.empno = current_user.empno
    render layout: false
  end

  def create
    @receipt_batch = ReceiptBatch.using('pg').new(receipt_batch_params)
    if @receipt_batch.save
      flash[:notice] = t('receipt_batch.created')
      redirect_to new_receipt_batch_receipt_item_path(@receipt_batch)
    else
      flash[:alert] = t('receipt_batch.not_created')
      render action: :new
    end
  end

  def edit
    render layout: false
  end

  def update
    if @receipt_batch.update(receipt_batch_params)
      redirect_to receipt_batches_path, notice: t('receipt_batch.updated')
    else
      flash[:alert] = t('receipt_batch.not_updated')
      render action: :editerr
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to receipt_batches_path, alert: t('receipt_batch.conflict')
  end

  def editerr
  end

  def destroy
    @receipt_batch.destroy
    if @receipt_batch.errors.count == 0
      flash[:notice] = t('receipt_batch.deleted')
    else
      flash[:alert] = t('receipt_batch.not_deleted') + ' ' + @receipt_batch.errors.full_messages.flatten.join(' ')
    end
    redirect_to receipt_batches_path
  rescue ActiveRecord::StaleObjectError
    redirect_to receipt_batches_path, alert: t('receipt_batch.conflict')
  end

  def start_putaway
    @receipt_batch.using('pg').receipt_items.each do |receipt_item|
      # if receipt_item.qty_remaining == 0
      #   receipt_item.mute = true
      #   receipt_item.save!
      # else
      if receipt_item.mute
        receipt_item.mute = false
        receipt_item.save!
      end
      # end
    end
    redirect_to receipt_batch_putaway_path(@receipt_batch)
  end

  def putaway
    @receipt_items = @receipt_batch.using('pg').receipt_items.includes(:receipt_locations).using('pg')
    @receipt_items = @receipt_items.where("description != '* Invalid Item'")
    # @receipt_items = @receipt_items.where(status_flag: true)
    @receipt_items = @receipt_items.order("case when receipt_items.mute is true then 1 else 0 end")
    current_size = userset_page_size('receipt_items')
    @receipt_items = @receipt_items.ordered.page(params[:page]).per(current_size)
    @receipt_location = ReceiptLocation.using('pg').new
    if params[:bin_loc]
      @receipt_location.receipt_item_id = params[:receipt_item_id]
      @receipt_location.stock_area = params[:stock_area]
      @receipt_location.bin_loc = params[:bin_loc]
      @receipt_location.loc_type = params[:loc_type]
      @receipt_location.quantity = params[:quantity]
    end
    # puts "44444 #{@receipt_location.inspect}"
    @tbdash_recv_putaway_locs = build_putaway_locs
  end

  def find_item
    # create = false
    @receipt_item_no = params[:receipt_item_no]
    # puts "SESSION FILTER: #{session[:filter].inspect}  ** #{session[:filter]['receipt_item_no'].inspect}"
    @receipt_item_no = session[:filter]['receipt_item_no'] unless @receipt_item_no && @receipt_item_no != '%'
    # puts "RECV ITEM NO: #{@receipt_item_no.inspect}"
    if params[:receipt_item_id]
      @receipt_item = ReceiptItem.using('pg').where(id: params[:receipt_item_id].to_i).first
    else
      # create = true
      @receipt_item = ReceiptItem.using('pg').new
      @receipt_item.receipt_batch_id = @receipt_batch.id
      @receipt_item.empno = @current_user.empno
      @receipt_item.item_no = @receipt_item_no
      @receipt_item.save
      @receipt_item.reload
    end
    @receipt_item_no = @receipt_item.item_no
    # puts "***** searching for #{@receipt_item_no}"
    if @receipt_item.item_no && @receipt_item.item_no != '%'
      @search_items = TbdashSimpleItem.using(@current_client.cust_no).for_search('%' + @receipt_item_no + '%').ordered
    else
      @search_items = TbdashSimpleItem.using(@current_client.cust_no).all.ordered
    end
    current_size = userset_page_size('search_items')
    @search_items = @search_items.page(params[:page]).per(current_size)
    # redirect_to edit_receipt_batch_receipt_item_path(@receipt_item.receipt_batch_id, @receipt_item) if create
  end

  def close
    close_ok = true
    @receipt_batch.using('pg').receipt_items.using('pg').includes(:receipt_locations).each do |receipt_item|
      # puts "*** #{receipt_item.qty_remaining.inspect}"
      close_ok = false if receipt_item.qty_remaining != 0
      # puts "*** setting close_ok to false"
    end
    # puts "***** close_ok #{close_ok.inspect}"
    if close_ok
      @receipt_batch.batch_status = 'Complete'
      @receipt_batch.save!
      mail_notifications
      flash[:notice] = t('receipt_batch.closed')
      redirect_to receipt_batches_path
    else
      flash[:alert] = t('receipt_batch.not_closed')
      redirect_to receipt_batch_putaway_path(@receipt_batch)
    end
  end

  def mute_all
    @receipt_batch.using('pg').receipt_items.each do |receipt_item|
      receipt_item.mute = true
      receipt_item.save!
    end
    redirect_to receipt_batch_putaway_path(@receipt_batch)
  end

  def unmute_all
    @receipt_batch.using('pg').receipt_items.each do |receipt_item|
      receipt_item.mute = false
      receipt_item.save!
    end
    redirect_to receipt_batch_putaway_path(@receipt_batch)
  end

  def from_upload
    @receipt_upload_hdr = ReceiptUploadHdr.using('tbdash').find(params[:upload_batch])
    @receipt_batch = ReceiptBatch.using('pg').create!(client_id: @current_client.id,
                                                      note: '',
                                                      batch_status: 'Open',
                                                      tracking_ref: @receipt_upload_hdr.tracking_ref,
                                                      dock_receipt_at: Time.now,
                                                      vendor_no: @receipt_upload_hdr.vendor_no,
                                                      receipt_upload_hdr_id: @receipt_upload_hdr.id,
                                                      po_ref: @receipt_upload_hdr.po_ref,
                                                      empno: current_user.empno)
    @receipt_upload_hdr.receipt_upload_dtls.each do |line|
      @receipt_item = ReceiptItem.using('pg').create(receipt_batch_id: @receipt_batch.id,
                                                     empno: @current_user.empno,
                                                     item_no: line.item_no,
                                                     quantity: line.quantity,
                                                     boxcount: line.boxcount,
                                                     vendor_id: line.vendor_id,
                                                     po_no: line.po_no,
                                                     shipment_no: line.shipment_no,
                                                     shipment_line: line.shipment_line,
                                                     shipment_date: line.shipment_date,
                                                     qty_shipped: line.qty_shipped)
      # puts "Line #{line.line_no} #{@receipt_item.errors.full_messages.flatten.join(' ')}"
    end
    @receipt_upload_hdr.upload_status = 'Uploaded'
    @receipt_upload_hdr.save!
    redirect_to new_receipt_batch_receipt_item_path(@receipt_batch)
  end

  def download_861
    send_data @receipt_batch.to_861, filename: "#{@receipt_batch.receipt_items.first&.shipment_no||@receipt_batch.id.to_s}.csv"
  end

  private

  def build_putaway_locs
    TbdashRecvItemTemp.using(@current_client.cust_no).delete_all
    TbdashRecvLocTemp.using(@current_client.cust_no).delete_all
    @receipt_batch.using('pg').receipt_items.using('pg').includes(:receipt_locations).where("item_no is not null").each do |receipt_item|
      TbdashRecvItemTemp.using(@current_client.cust_no).create!(item_no: receipt_item.item_no, quantity: receipt_item.quantity) unless receipt_item.mute == true ||
          # receipt_item.status_flag == false ||
          receipt_item.description == '* Invalid Item' ||
          receipt_item.qty_remaining == 0 # LJK 11-23-17 added
    end
    first = true
    # LJK 12-14-17 this was incorrect, needs to be limited to current batch
    #   ReceiptLocation.where("receipt_item_id in (select receipt_item_id \
    #from receipt_batches, receipt_items where receipt_batches.id = receipt_items.receipt_batch_id and receipt_batches.id = ?)",
    #                          @receipt_batch.id).order(id: :desc).each do |receipt_location|
    # LJK 12-14-17 sort of messes up the 'most recent' functionality, need better way to get all receipt locations for batch
    @receipt_batch.using('pg').receipt_locations.order(id: :desc).each do |receipt_location|

      TbdashRecvLocTemp.using(@current_client.cust_no).create!(item_no: receipt_location.receipt_item.item_no, stock_area: receipt_location.stock_area,
                                                               bin_loc: receipt_location.bin_loc, most_recent: (first ? 'Y' : 'N'))
      first = false
    end
    TbdashRecvPutawayLoc.using(@current_client.cust_no).order(:precedence).order(:stock_area).order(:bin_loc).limit(20)
  end

  def get_receipt_batch
    if params[:id]
      @receipt_batch = ReceiptBatch.using('pg').find(params[:id].to_i)
    else
      @receipt_batch = ReceiptBatch.using('pg').find(params[:receipt_batch_id].to_i)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to receipt_batches_path, alert: t('receipt_batch.not_found')
  end

  def receipt_batch_params
    params.require(:receipt_batch).permit(:client_id, :note, :batch_status, :lock_version, :tracking_ref, :dock_receipt_at, :vendor_no, :po_ref)
  end

  def get_vendors
    @tbdash_vendors = TbdashVendor.using(@current_client.cust_no).ordered
  end

  def mail_notifications
    ReceiverMailer.delay(queue: DelayedJob::MAILER, client_id: @current_client.id)
                  .receiver(@current_client.id, @receipt_batch.id)
    @receipt_batch.receipt_items.each do |receipt_item|
      TbdashItemComment.using(@current_client.cust_no)
                       .where(item_no: receipt_item.item_no)
                       .for_type('TBRC').each do |item_comment|
        Octopus.using('pg') do
        ReceiverCommentMailer.delay(queue: DelayedJob::MAILER, client_id: @current_client.id)
                             .send_comment(@current_client.id, @receipt_batch.id,
                                      receipt_item.id, item_comment.comment_text)
        end
      end
    end
  end

end
