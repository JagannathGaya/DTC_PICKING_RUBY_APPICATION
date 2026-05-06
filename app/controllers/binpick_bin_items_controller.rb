class BinpickBinItemsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter
  before_action :get_binpick_bin_item, only: [:edit, :update]
  ITEM_BACKORDER = 'B'
  ITEM_CLOSE = 'C'
  ITEM_OPEN = 'O'

  def index
    @binpick_bin = BinpickBin.using(@current_client.cust_no).find(params['binpick_bin_id'])
    @binpick_bin_items = BinpickBinItem.using(@current_client.cust_no).for_bin(params['binpick_bin_id']).ordered

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def edit
    @binpick_bin_item.all_orders_exceptions_present = params[:exceptions_present]
    @binpick_bin_item.status = ITEM_BACKORDER # only thing they can do here...
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    puts "BinpickBinItems#update params = #{params.inspect}"
    first_short_order_seq = params[:binpick_bin_item][:first_short_order_seq].to_i
    action = params[:binpick_bin_item][:status]
    puts "Action = #{action} first_short_order_seq = #{first_short_order_seq}"
    if action == ITEM_BACKORDER
      bin_item_backorder_action(action, first_short_order_seq)
    else
      flash[:alert] = "Invalid binpick_bin_item action!"
      redirect_to new_binpick_bin_path
    end
  end

  def bin_item_backorder
    bin_item_backorder_action(ITEM_BACKORDER)
  end

  def bin_item_bo_reverse
    bin_item_backorder_action(ITEM_OPEN)
  end

  def bin_item_backorder_action(action, first_short_order_seq = 0)
    BinpickBinItem.transaction do
      BinpickBin.transaction do
        puts "#bin_item_backorder_action bin item instance = #{@binpick_bin_item}"
        # only fetch if we don't already have it
        @binpick_bin_item ||= BinpickBinItem.using(@current_client.cust_no).find(params[:binpick_bin_item_id])
        @binpick_bin_item.status = action
        @binpick_bin_item.first_short_order_seq = first_short_order_seq
        @binpick_bin_item.empno = current_user.empno
        @binpick_bin_item.save
        if action == ITEM_BACKORDER
          flash[:notice] = t('binpick_bin.bin_backordered', item: @binpick_bin_item.item_display)
        else
          flash[:notice] = t('binpick_bin.bin_bo_reversed', item: @binpick_bin_item.item_display)
          end
        @binpick_bin_item_remaining = BinpickBinItem.using(@current_client.cust_no)
                                          .where(binpick_bin_id: @binpick_bin_item.binpick_bin_id)
                                          .pickable_item.first
        @binpick_bin = @binpick_bin_item.binpick_bin
        # puts "binpick bin status = #{@binpick_bin.status} remaining = #{@binpick_bin_item_remaining}}"
        if (@binpick_bin.completed? && @binpick_bin_item_remaining) || (@binpick_bin.open? && !@binpick_bin_item_remaining) # prevent unnecessary updates to bin
          if @binpick_bin_item_remaining
            @binpick_bin.status = BinpickBin::OPEN
          else
            @binpick_bin.status = BinpickBin::COMPLETE
          end
          @binpick_bin.empno = nil
          @binpick_bin.save
        end
      end
    end
    if action == ITEM_OPEN
      redirect_to binpick_batches_path
    else
      redirect_to new_binpick_bin_path
    end
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Backorder process FAILED error = #{e.inspect}"
    puts "*************** Binpick Backorder process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to new_binpick_bin_path and return
  end

  def autopick_all_orders
    BinpickBinItem.transaction do
      BinpickBin.transaction do
        @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(params[:binpick_bin_item_id])
        @binpick_bin_item.status = ITEM_CLOSE
        @binpick_bin_item.empno = current_user.empno
        @binpick_bin_item.save
        flash[:notice] = t('binpick_bin.bin_autopicked', item: @binpick_bin_item.item_display)
        @binpick_bin_item_remaining = BinpickBinItem.using(@current_client.cust_no)
                                          .where(binpick_bin_id: @binpick_bin_item.binpick_bin_id)
                                          .pickable_item.first
        unless @binpick_bin_item_remaining
          @binpick_bin = @binpick_bin_item.binpick_bin
          @binpick_bin.status = BinpickBin::COMPLETE
          @binpick_bin.empno = nil
          @binpick_bin.save
        end
      end
    end
    redirect_to new_binpick_bin_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Autopick process FAILED error = #{e.inspect}"
    puts "*************** Binpick Autopick process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to new_binpick_bin_path and return
  end


  private

  def get_binpick_bin_item
    puts "#get_binpick_bin_item params = #{params}"
    @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(params[:id].to_i)
    puts "fetched #{@binpick_bin_item.inspect}"
  end

end
