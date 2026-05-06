class ReceiptLocationsController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :ensure_minimum_filter
  # before_action :get_receipt_item, only: [:create]

  def index
    @receipt_batch = ReceiptBatch.using('pg').find(params[:receipt_batch_id].to_i)
    @receipt_locations = ReceiptLocation.using('pg').includes(:receipt_item).where("receipt_item_id in (select receipt_items.id \
from receipt_batches, receipt_items where receipt_batches.id = receipt_items.receipt_batch_id and receipt_batches.id = ?)",
                                                                       @receipt_batch.id)
    @receipt_locations = @receipt_locations.order(:stock_area).order(:bin_loc)
    current_size = userset_page_size('receipt_locations')
    @receipt_locations = @receipt_locations.page(params[:page]).per(current_size)
  end

  def new
    receipt_batch_id = params[:receipt_batch_id] if params[:receipt_batch_id]
    if @receipt_location
      @receipt_item = @receipt_location.receipt_item
    else
      @receipt_item = ReceiptItem.using('pg').find(params[:receipt_item_id].to_i) if params[:receipt_item_id]
      @receipt_item = ReceiptItem.using('pg').where(receipt_batch_id: params[:receipt_batch_id], item_no: params[:receipt_item_no]).first if params[:receipt_item_no] if params[:receipt_batch_id] unless @receipt_item
      @receipt_location = ReceiptLocation.using('pg').new
    end
    if @receipt_item
      @receipt_location.receipt_item_id = @receipt_item.id
      @receipt_location.quantity = @receipt_item.quantity
      receipt_batch_id ||= @receipt_item.receipt_batch_id
    else
    end
    @receipt_location.stock_area = params[:stock_area] if params[:stock_area]
    @receipt_location.bin_loc = params[:bin_loc] if params[:bin_loc]
    @receipt_location.loc_type = params[:loc_type] if params[:loc_type]

    redirect_to receipt_batch_putaway_path(receipt_batch_id, receipt_item_id: @receipt_location.receipt_item_id,
                                           stock_area: @receipt_location.stock_area,
                                           bin_loc: @receipt_location.bin_loc,
                                           loc_type: @receipt_location.loc_type,
                                           quantity: (@receipt_item ? @receipt_item.qty_remaining : 0))
  end

  def create
    # puts "ReceiptLocationsController#create current_client = #{@current_client}"
    @receipt_batch = ReceiptBatch.using('pg').find(params[:receipt_batch_id].to_i)
    result = true
    if params[:receipt_location][:receipt_item_id].to_i == -1
      @receipt_items = @receipt_batch.using('pg').receipt_items.using('pg').includes(:receipt_locations)
      @receipt_items = @receipt_items.where("description != '* Invalid Item'")
      @receipt_items = @receipt_items.where(mute: false)
      # puts "ReceiptLocationsController#create IF receipt_items = #{@receipt_items.inspect}"
      @receipt_items.each do |receipt_item|
        if receipt_item.qty_remaining > 0
          receipt_location = ReceiptLocation.using('pg').new(receipt_location_params)
          receipt_location.receipt_item = receipt_item
          receipt_location.quantity = receipt_item.qty_remaining
          result = post_one_location(receipt_location)
        end
        break unless result
      end
    else
      receipt_location = ReceiptLocation.using('pg').new(receipt_location_params)
   #   puts "ReceiptLocationsController#create ELSE receipt_location = #{receipt_location.inspect}"
      result = post_one_location(receipt_location)
    end
    try_update_batch(@receipt_batch) if result
    redirect_to receipt_batch_putaway_path(@receipt_batch)
  end

  def post_one_location(receipt_location)
    savable = receipt_location.save
    if savable
      res = ReceiptOracleService.new(receipt_location, @current_client).send_to_oracle
      receipt_location.using('pg').reload
      receipt_location.using('pg').receipt_item.note = receipt_location.receipt_item.status_flag ? nil : 'Made Active'
      receipt_location.using('pg').receipt_item.save
      if res
        receipt_location.delete
        flash[:alert] = t('receipt_location.not_created') + ' ' + res
        return false
        else
        flash[:notice] = t('receipt_location.created')
        return true
      end
    else
      flash[:alert] = t('receipt_location.not_created') + ' ' + receipt_location.errors.full_messages.flatten.join(' ')
      return false
    end
  end

  private

  def get_receipt_item
    @receipt_item = ReceiptItem.using('pg').find(params[:receipt_item_id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to receipt_batches_path, alert: t('receipt_item.not_found')
  end

  def get_receipt_location
    if params[:id]
      @receipt_location = ReceiptLocation.using('pg').find(params[:id].to_i)
    else
      @receipt_location = ReceiptLocation.using('pg').find(params[:receipt_location_id].to_i)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_receipt_location_path, alert: t('receipt_location.not_found')
  end

  def receipt_location_params
    params.require(:receipt_location).permit(:receipt_item_id, :stock_area, :bin_loc, :quantity, :lock_version, :fast_reference, :new_default, :loc_type)
  end

  def try_update_batch(receipt_batch)
    receipt_batch.using('pg').receipt_items.using('pg').includes(:receipt_locations).each do |receipt_item|
      return if receipt_item.qty_remaining != 0 ||
          # receipt_item.status_flag == false ||
          receipt_item.description == '* Invalid Item'
    end
    receipt_batch.batch_status = 'Pending'
    receipt_batch.save!
  end

end
