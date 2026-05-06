class BinpickBinsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter
  before_action :get_binpick_batch
  ITEM_OPEN = 'O'

  def new
    if action_permitted?(binpick_bins_path, current_user) && @current_client_location
      @binpick_bin = BinpickBin.using(@current_client.cust_no)
				.for_batch(@binpick_batch.id)
                               .for_employee(@current_user.empno).scopen.first
      # puts "BinpickBin#new empno = bin = #{@binpick_bin.inspect}"
      if @binpick_bin
        redirect_to binpick_bin_path(@binpick_bin.id.to_i, anchor: "top") and return
      end
      @binpick_bin = BinpickBin.using(@current_client.cust_no).new
      @binpick_bin_summaries = BinpickBinSummary.using(@current_client.cust_no)
                                                .for_batch(@binpick_batch.id).for_bin_list.limit(20)
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path and return # makes it clearer that no more code should be executed in this method
    end
  end

  def change_batch
    session[:bo_option] = (@binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                            BinpickBatch::NEWORDERS : BinpickBatch::BACKORDERS
    get_binpick_batch
    @binpick_bin = BinpickBin.using(@current_client.cust_no).new
    @binpick_bin_summaries = BinpickBinSummary.using(@current_client.cust_no)
                                              .for_batch(@binpick_batch.id).for_bin_list.limit(20)
    render :new
  end

  def create
    clear_filters
    @binpick_bin = identify_binpick_bin
    if @binpick_bin
      @binpick_bin.empno = @current_user.empno
      @binpick_bin.binpick_batch_id = @binpick_batch.id
      @binpick_bin.status = 'O' if @binpick_bin.status == 'D'
      @binpick_bin.save!
      # Fetch open items and make them open! 9/12/2020
      # @binpick_bin.binpick_bin_items.pickable_item.each do |binpick_bin_item|
      #   binpick_bin_item.status = ITEM_OPEN
      #   binpick_bin_item.save!
      # end
      redirect_to binpick_bin_path(@binpick_bin.id.to_i, anchor: "top") and return
    end
    redirect_to new_binpick_bin_path
  end

  def show
    # puts " SORT #{session[:sortkey].inspect} #{session[:sortdir].inspect}"
    @orderline_actions = BinpickOrderLine::ACTION_LIST
    @binpick_bin = BinpickBin.using(@current_client.cust_no).find(params[:id])
    @binpick_bin_items = @binpick_bin.binpick_bin_items.pickable_item
    if @binpick_bin.pick_all_orders?
      @binpick_order_lines = @binpick_bin.binpick_order_lines.shippable.scopen.qty_exception
    else
      @binpick_order_lines = @binpick_bin.binpick_order_lines.shippable
    end

    if session[:sortkey]
      puts "BinpickBin#show sortkey = #{session[:sortkey]}"
      @binpick_order_lines = @binpick_order_lines.order("#{session[:sortkey]} #{session[:sortdir].upcase}")
    else
      @binpick_order_lines = @binpick_order_lines.ordered
    end
    current_size = userset_page_size('binpick_order_lines', 10)
    count_done = 0
    unless @binpick_bin.pick_all_orders?
      if filter('orderline_action_filter') == 'R'
        count_done = @binpick_order_lines.where.not(action: 'N').count - 2
        count_done = count_done.negative? ? 0 : count_done
        @binpick_order_lines = @binpick_order_lines.for_action('A')
        session[:filter]['orderline_action_filter'] = 'N'
      else
        @binpick_order_lines = @binpick_order_lines.for_action(filter('orderline_action_filter') || 'N')
      end
    end
    if count_done > current_size
      offset = (count_done / current_size).truncate + 1
      @binpick_order_lines = @binpick_order_lines.page(offset).per(current_size)
    else
      @binpick_order_lines = @binpick_order_lines.page(params[:page]).per(current_size)
    end
    puts "#show all orders = #{@binpick_bin.pick_all_orders?} bin_items = #{@binpick_bin_items.inspect} lines = #{@binpick_order_lines.count}"
  end

  def deassign
    @binpick_bin = BinpickBin.using(@current_client.cust_no).find(params[:binpick_bin_id])
    @binpick_bin.empno = nil
    @binpick_bin.save!
    redirect_to binpick_batches_path
  end

  def release
    @binpick_bin = BinpickBin.using(@current_client.cust_no).find(params[:binpick_bin_id])
    @binpick_bin.empno = nil
    @binpick_bin.save!
    redirect_to new_binpick_bin_path
  end

  def defer
    @binpick_bin = BinpickBin.using(@current_client.cust_no).find(params[:binpick_bin_id])
    @binpick_bin.empno = nil
    @binpick_bin.status = 'D'
    @binpick_bin.save!
    redirect_to new_binpick_bin_path
  end

  private

  def get_binpick_batch
    # @binpick_batch = BinpickBatch.using('pg').where(client_id: @current_client.id).scopen.first
    @binpick_batch = if session[:bo_option]
                       BinpickBatch.using('pg').
                         where(client_id: @current_client.id).
                         where(client_location_id: @current_client_location.id).
                         pickable.where(bo_option: session[:bo_option]).first
                     else
                       BinpickBatch.using('pg').
                         where(client_id: @current_client.id).
                         where(client_location_id: @current_client_location.id).
                         pickable.first
                     end
    unless @binpick_batch
      flash[:alert] = t('binpick_bin.no_open_batch')
      redirect_to root_path
    end
  end

  def identify_binpick_bin
    scanner_entry = params[:binpick_bin][:bin_loc] # hijacked 11 chr field for scanner entry
    parsed_entry = scanner_entry.split('+')
    prefix = parsed_entry[0]
    stock_area = parsed_entry[1]
    bin_loc = parsed_entry[2]
    # puts "Scanner entry #{scanner_entry} prefix = #{scanner_entry.split('+')[0]}"
    if prefix != '.S'
      flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
      return
    end
    binpick_bin = BinpickBin.using(@current_client.cust_no).for_batch(@binpick_batch)
                            .where(stock_area: stock_area, bin_loc: bin_loc).first
    unless binpick_bin
      flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
      return
    end
    # This condition is always true! 9/12/2020
    # unless binpick_bin.pickable
    #   flash[:alert] = t('binpick_bin.not_pickable')
    #   return
    # end
    # puts "BIN #{binpick_bin.inspect}"
    if binpick_bin.empno && binpick_bin.empno != @current_user.empno
      flash[:alert] = t('binpick_bin.get_your_own_bin', owner: binpick_bin.empno)
      return
    end
    binpick_bin
  end

end
