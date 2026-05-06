class BinpickOrderLinesController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter
  before_action :get_binpick_batch, only: [:wave_picks]
  BIN_OPEN = 'O'
  BIN_COMPLETE = 'C'
  ITEM_OPEN = 'O'
  ITEM_COMPLETE = 'C'
  LINE_OPEN = 'N'
  LINE_SHIPPED = 'S'
  BACKORDER = 'B'

  def index
    @binpick_order = BinpickOrder.using(@current_client.cust_no).find(params['binpick_order_id'])
    @binpick_order_lines = BinpickOrderLine.using(@current_client.cust_no).for_order(params['binpick_order_id']).ordered
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def wave_picks
    @binpick_order_lines = BinpickOrderLine.using(@current_client.cust_no).for_batch(@binpick_batch.id).shippable.wave_ordered
    respond_to do |format|
      format.html
    end
  end

  def line_count
    @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(params['binpick_bin_item_id'])
    @binpick_order_lines = BinpickOrderLine.using(@current_client.cust_no).for_bin_item(params['binpick_bin_item_id']).ordered
    @binpick_order_lines = @binpick_order_lines.scopen if params['open_qty']
    @binpick_order_lines = @binpick_order_lines.shipped if params['qty_shipped']
    @binpick_order_lines = @binpick_order_lines.backordered if params['qty_backordered']
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def confirm
    #   puts "BinpickOrderLines#confirm"
    BinpickOrderLine.transaction do
      BinpickBinItem.transaction do
        BinpickBin.transaction do
          @binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:binpick_order_line_id].to_i)
          unless @binpick_order_line.shippable?
            flash[:alert] = "Order #{@binpick_order_line.order_no}-#{@binpick_order_line.order_suffix} ID #{@binpick_order_line.order_seq.to_i} is no longer in shipping status, cannot confirm."
            redirect_to new_binpick_bin_path and return
          end
          @binpick_order_line.action = LINE_SHIPPED
          @binpick_order_line.empno = @current_user.empno
          @binpick_order_line.save
          @binpick_order_line_remaining = BinpickOrderLine.using(@current_client.cust_no)
                                                          .where(binpick_bin_item_id: @binpick_order_line.binpick_bin_item_id)
                                                          .scopen.first
          unless @binpick_order_line_remaining
            @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(@binpick_order_line.binpick_bin_item_id)
            @binpick_bin_item.status = ITEM_COMPLETE
            @binpick_bin_item.empno = @current_user.empno
            @binpick_bin_item.save
            @binpick_bin_item_remaining = BinpickBinItem.using(@current_client.cust_no)
                                                        .where(binpick_bin_id: @binpick_bin_item.binpick_bin_id)
                                                        .pickable_item.first
            unless @binpick_bin_item_remaining
              @binpick_bin = BinpickBin.using(@current_client.cust_no).find(@binpick_bin_item.binpick_bin_id)
              @binpick_bin.empno = @current_user.empno
              @binpick_bin.status = BIN_COMPLETE
              @binpick_bin.save
            end
          end
        end
      end
    end
    redirect_to new_binpick_bin_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Order Line Confirm process FAILED error = #{e.inspect}"
    puts "*************** Binpick Order Line Confirm process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to new_binpick_bin_path
  end

  def wave_confirm
    #  puts "BinpickOrderLine.wave_confirm"
    binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i) # TODO: This is redundant and ugly, but we can't get at it when scoped by transactions
    batch_id = binpick_order_line.binpick_batch_id.to_i
    BinpickOrderLine.transaction do
      BinpickBinItem.transaction do
        BinpickBin.transaction do
          @binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i)
          @batch_id = @binpick_order_line.binpick_batch_id.to_i
          unless @binpick_order_line.shippable?
            flash[:alert] = "Order #{@binpick_order_line.order_no}-#{@binpick_order_line.order_suffix} ID #{@binpick_order_line.order_seq.to_i} is no longer in shipping status, cannot confirm."
            puts "confirm not shippable..."
            redirect_to binpick_wave_picks_path(@binpick_order_line.binpick_batch_id.to_i) and return
          end
          @binpick_order_line.action = LINE_SHIPPED
          @binpick_order_line.empno = @current_user.empno
          @binpick_order_line.save
          @binpick_order_line_remaining = BinpickOrderLine.using(@current_client.cust_no)
                                                          .where(binpick_bin_item_id: @binpick_order_line.binpick_bin_item_id)
                                                          .scopen.first
          unless @binpick_order_line_remaining
            @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(@binpick_order_line.binpick_bin_item_id)
            @binpick_bin_item.status = ITEM_COMPLETE
            @binpick_bin_item.empno = @current_user.empno
            @binpick_bin_item.save
            @binpick_bin_item_remaining = BinpickBinItem.using(@current_client.cust_no)
                                                        .where(binpick_bin_id: @binpick_bin_item.binpick_bin_id)
                                                        .pickable_item.first
            unless @binpick_bin_item_remaining
              @binpick_bin = BinpickBin.using(@current_client.cust_no).find(@binpick_bin_item.binpick_bin_id)
              @binpick_bin.empno = @current_user.empno
              @binpick_bin.status = BIN_COMPLETE
              @binpick_bin.save
            end
          end
        end
      end
    end
    puts "wave_confirm end, redirecting"
    redirect_to binpick_wave_picks_path(batch_id)
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Order Line Confirm process FAILED error = #{e.inspect}"
    puts "*************** Binpick Order Line Confirm process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to binpick_wave_picks_path(batch_id)
  end

  def unconfirm
    #  puts "BinpickOrderLine#unconfirm"
    BinpickOrderLine.transaction do
      BinpickBinItem.transaction do
        BinpickBin.transaction do
          @binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:binpick_order_line_id].to_i)
          @binpick_order_line.action = LINE_OPEN
          @binpick_order_line.save
          @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(@binpick_order_line.binpick_bin_item_id)
          unless @binpick_bin_item.status == ITEM_OPEN
            @binpick_bin_item.status = ITEM_OPEN
            @binpick_bin_item.save
          end
          @binpick_bin = BinpickBin.using(@current_client.cust_no).find(@binpick_bin_item.binpick_bin_id.to_i)
          unless @binpick_bin.status == BIN_OPEN
            @binpick_bin.status = BIN_OPEN
            @binpick_bin.save
          end
        end
      end
    end
    redirect_to new_binpick_bin_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Order Line Unconfirm process FAILED error = #{e.inspect}"
    puts "*************** Binpick Order Line Unconfirm process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to new_binpick_bin_path and return
  end

  def wave_unconfirm
    #   puts "BinpickOrderLine#wave_unconfirm"
    binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i)
    batch_id = binpick_order_line.binpick_batch_id.to_i
    BinpickOrderLine.transaction do
      BinpickBinItem.transaction do
        BinpickBin.transaction do
          @binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i)
          @binpick_order_line.action = LINE_OPEN
          @binpick_order_line.save
          @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(@binpick_order_line.binpick_bin_item_id)
          unless @binpick_bin_item.status == ITEM_OPEN
            @binpick_bin_item.status = ITEM_OPEN
            @binpick_bin_item.save
          end
          @binpick_bin = BinpickBin.using(@current_client.cust_no).find(@binpick_bin_item.binpick_bin_id.to_i)
          unless @binpick_bin.status == BIN_OPEN
            @binpick_bin.status = BIN_OPEN
            @binpick_bin.save
          end
        end
      end
    end
    redirect_to binpick_wave_picks_path(batch_id)
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Order Line Unconfirm process FAILED error = #{e.inspect}"
    puts "*************** Binpick Order Line Unconfirm process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to binpick_wave_picks_path(batch_id)
  end

  def wave_backorder
    #  puts "BinpickOrderLine#backorder"
    binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i)
    batch_id = binpick_order_line.binpick_batch_id.to_i
    BinpickOrderLine.transaction do
      BinpickBinItem.transaction do
        BinpickBin.transaction do
          @binpick_order_line = BinpickOrderLine.using(@current_client.cust_no).find(params[:id].to_i)
          @batch_id = @binpick_order_line.binpick_batch_id.to_i
          unless @binpick_order_line.shippable?
            flash[:alert] = "Order #{@binpick_order_line.order_no}-#{@binpick_order_line.order_suffix} ID #{@binpick_order_line.order_seq.to_i} is no longer in shipping status, cannot confirm."
            puts "confirm not shippable..."
            redirect_to binpick_wave_picks_path(@binpick_order_line.binpick_batch_id.to_i) and return
          end
          @binpick_order_line.action = BACKORDER
          @binpick_order_line.empno = @current_user.empno
          puts "Backorder, line = #{@binpick_order_line.inspect}"
          @binpick_order_line.save!
          @binpick_order_line_remaining = BinpickOrderLine.using(@current_client.cust_no)
                                                          .where(binpick_bin_item_id: @binpick_order_line.binpick_bin_item_id)
                                                          .scopen.first
          unless @binpick_order_line_remaining
            @binpick_bin_item = BinpickBinItem.using(@current_client.cust_no).find(@binpick_order_line.binpick_bin_item_id)
            @binpick_bin_item.status = ITEM_COMPLETE
            @binpick_bin_item.empno = @current_user.empno
            @binpick_bin_item.save
            @binpick_bin_item_remaining = BinpickBinItem.using(@current_client.cust_no)
                                                        .where(binpick_bin_id: @binpick_bin_item.binpick_bin_id)
                                                        .pickable_item.first
            unless @binpick_bin_item_remaining
              @binpick_bin = BinpickBin.using(@current_client.cust_no).find(@binpick_bin_item.binpick_bin_id)
              @binpick_bin.empno = @current_user.empno
              @binpick_bin.status = BIN_COMPLETE
              @binpick_bin.save
            end
          end
        end
      end
    end
    redirect_to binpick_wave_picks_path(batch_id)
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Order Line Backorder process FAILED error = #{e.inspect}"
    puts "*************** Binpick Order Line Backorder process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to binpick_wave_picks_path(batch_id)
  end

  private

  def get_binpick_batch
    @binpick_batch = BinpickBatch.find params['binpick_batch_id']
  end

end
