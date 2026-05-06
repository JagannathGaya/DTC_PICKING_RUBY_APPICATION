class ReceiptItemsController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :ensure_minimum_filter
  before_action :get_receipt_batch
  before_action :get_receipt_item, only: [:destroy, :edit, :update, :found_item, :mute, :edit_label, :select_default, :putaway_label]

  def index
    fetch_items_list
  end

  def new
    fetch_items_list
    #   puts "***1*** #{@receipt_item.inspect}"
    unless @receipt_item
      @receipt_item = ReceiptItem.using('pg').for_batch(@receipt_batch.id).order(id: :desc).first
      #   puts "***2*** #{@receipt_item.inspect}"
      if @receipt_item.nil? || @receipt_item.item_no
        @receipt_item = ReceiptItem.using('pg').new
        @receipt_item.receipt_batch_id = @receipt_batch.id
        @receipt_item.empno = @current_user.empno
        @item_comments = []
      end
    end
    #   puts "***3*** #{@receipt_item.inspect}"
    unless @receipt_item.item_no.nil?
      @item_comments = TbdashItemComment.using(@current_client.cust_no).where(item_no: @receipt_item.item_no).for_type('RE')
    end
  end

  def create
    #
    @receipt_item = ReceiptItem.using('pg').new(receipt_item_params)
    # @receipt_item.boxcount = 0 if @receipt_item.boxcount == '' || @receipt_item.boxcount.nil?
    # @receipt_item.quantity = 0 if @receipt_item.quantity == '' || @receipt_item.quantity.nil?
    # puts "receipt_item = #{@receipt_item.inspect}"
    tbdash_item = TbdashSimpleItem.using(@current_client.cust_no).where(item_no: @receipt_item.item_no).first
    @receipt_item.searched = true unless tbdash_item
    if @receipt_item.save
      if params[:find_item]
        redirect_to receipt_batch_find_item_path(@receipt_batch, receipt_item_id: @receipt_item.id)
      else
        if @receipt_item.description == '* Invalid Item'
          flash[:alert] = t('receipt_item.created_bad_item')
        else
          flash[:notice] = t('receipt_item.created')
        end
        fetch_items_list
        if params[:commit] == t('receipt_item.find_item')
          redirect_to receipt_batch_find_item_path(@receipt_batch, receipt_item_id: @receipt_item.id)
        else
          redirect_to new_receipt_batch_receipt_item_path(@receipt_batch)
        end
      end
    else
      flash[:alert] = t('receipt_item.not_created') + ' ' + @receipt_item.errors.full_messages.flatten.join(' ')
      fetch_items_list
      render action: :new
    end
  end

  def found_item
    @receipt_item.item_no = params[:item_id]
    @receipt_item.searched = true
    @receipt_item.save
    flash[:notice] = t('receipt_item.updated')
    @item_comments = TbdashItemComment.using(@current_client.cust_no).where(item_no: @receipt_item.item_no).for_type('RE')
    fetch_items_list
    render action: :new
    # redirect_to new_receipt_batch_receipt_item_path(@receipt_batch)
  end

  def edit
    @item_comments = TbdashItemComment.using(@current_client.cust_no).where(item_no: @receipt_item.item_no).for_type('RE')
    fetch_items_list
  end

  def update
    if @receipt_item.update(receipt_item_params)
      fetch_items_list
      case
      when print_label?
        print_label
        if params["putaway"] && params["putaway"] == 'true'
          redirect_to receipt_batch_putaway_path(@receipt_batch), notice: t('receipt_item.label_printed')
        else
          redirect_to new_receipt_batch_receipt_item_path(@receipt_batch), notice: t('receipt_item.label_printed')
        end
        return
      when find_item?
        redirect_to receipt_batch_find_item_path(@receipt_batch, receipt_item_id: @receipt_item.id)
        return
      else
        redirect_to new_receipt_batch_receipt_item_path(@receipt_batch), notice: t('receipt_item.updated')
        return
      end
    else
      flash[:alert] = t('receipt_item.not_updated') + ' ' + @receipt_item.errors.full_messages.flatten.join(' ')
      fetch_items_list
      render action: :editerr
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to new_receipt_batch_receipt_item_path(@receipt_batch), alert: t('receipt_item.conflict')
  end

  def editerr
  end

  def destroy
    @receipt_item.destroy
    if @receipt_item.errors.count == 0
      flash[:notice] = t('receipt_item.deleted')
    else
      flash[:alert] = t('receipt_item.not_deleted') + ' ' + @receipt_item.errors.full_messages.flatten.join(' ')
    end
    fetch_items_list
    redirect_to new_receipt_batch_receipt_item_path(@receipt_batch)
  rescue ActiveRecord::StaleObjectError
    redirect_to new_receipt_batch_receipt_item_path(@receipt_batch), alert: t('receipt_item.conflict')
  end

  def mute
    @receipt_item.mute = !@receipt_item.mute
    if @receipt_item.save
      flash[:notice] = t('receipt_item.updated')
    else
      flash[:alert] = t('receipt_item.not_updated') + ' ' + @receipt_item.errors.full_messages.flatten.join(' ')
    end
    redirect_to receipt_batch_putaway_path(@receipt_item.receipt_batch_id)
  end

  def edit_label
    respond_to do |format|
      format.html {render layout: false}
    end
  end

  def putaway_label
    respond_to do |format|
      format.html {render layout: false}
    end
  end

  def select_default
    TbdashRecvItemTemp.using(@current_client.cust_no).delete_all
    TbdashRecvItemTemp.using(@current_client.cust_no).create!(item_no: @receipt_item.item_no, quantity: @receipt_item.quantity)
    @receipt_location = TbdashRecvPutawayLoc.using(@current_client.cust_no).where(loc_type: 'DEFAULT').first
    if @receipt_location
      redirect_to receipt_batch_putaway_path(@receipt_batch.id, receipt_item_id: @receipt_item.id,
                                             stock_area: @receipt_location.stock_area,
                                             bin_loc: @receipt_location.bin_loc,
                                             loc_type: @receipt_location.loc_type,
                                             quantity: (@receipt_item ? @receipt_item.qty_remaining : 0))
    else
      redirect_to receipt_batch_putaway_path(@receipt_item.receipt_batch_id)
    end
  end

  private

  # attempt to make button tests more idiomatic
  def save?
    !params[:save].nil?
  end

  def print_label?
    !params[:print_label].nil?
  end

  def find_item?
    !params[:find_item].nil?
  end


  def print_label
    # l = LabelDelegate.new("label_#{@receipt_item.id.to_s}.xml", Rails.application.config.label_path[:receiving], @receipt_item.to_btxml(1))
    l = LabelDelegate.new("label_#{@receipt_item.id.to_s}.dd", Rails.application.config.label_path[:receiving], @receipt_item.to_csv(@receipt_item.label_copies))
    l.write_file
  end

  def get_receipt_batch
    @receipt_batch = ReceiptBatch.using('pg').find(params[:receipt_batch_id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to receipt_batches_path, alert: t('receipt_batch.not_found')
  end

  def get_receipt_item
    if params[:id]
      @receipt_item = ReceiptItem.using('pg').find(params[:id].to_i)
    else
      @receipt_item = ReceiptItem.using('pg').find(params[:receipt_item_id].to_i)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to receipt_batch_receipt_items_path, alert: t('receipt_item.not_found')
  end

  def receipt_item_params
    params.require(:receipt_item).permit(:receipt_batch_id, :item_no, :boxcount, :empno, :quantity,
                                         :searched, :lock_version, :label_copies, :comment, :note)
  end

  def fetch_items_list
    ReceiptItem.using('pg').for_batch(@receipt_batch.id).where(description: '* Invalid Item', boxcount: 0, quantity: 0).destroy_all
    @receipt_items = ReceiptItem.using('pg').for_batch(@receipt_batch.id).includes(:receipt_locations)
    current_size = userset_page_size('receipt_items')
    @receipt_items = @receipt_items.ordered.page(params[:page]).per(current_size)
  end

end
