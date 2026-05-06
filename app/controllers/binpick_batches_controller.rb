# frozen_string_literal: true

class BinpickBatchesController < ApplicationController
  around_action :set_pg_shard
  before_action :authorize_host!
  before_action :ensure_minimum_filter
  BATCH_OPEN = 'O'
  BATCH_NEW = 'I'
  BATCH_PROCESS = 'P'
  BATCH_CONFIRMED = 'S'
  BATCH_COMPLETE = 'C'
  BATCH_CREATING = 'B'
  PICKED_COMPLETE = 'K'
  WAITING_PACK = 'W'
  BATCH_CANCEL = 'X'
  BIN_ASSIGNED = 'Assigned'
  ALL_ORDERS = 'A'

  def index
    if action_permitted?(binpick_batches_path, current_user) && @current_client_location
      puts "binpick_batches#index"
      @binpick_batch = get_binpick_batch
      puts "after get_binpick_batch"
      if @binpick_batch
        if @binpick_batch.status == BATCH_CREATING
          @binpick_batch_summaries = BinpickBatchSummary.using(@current_client.cust_no)
                                                        .for_location(@current_client_location.sls_location)
                                                        .for_status(BATCH_NEW).ordered
        else
          @binpick_batch_summaries = BinpickBatchSummary.using(@current_client.cust_no)
                                                        .for_batch(@binpick_batch.id).for_location(@current_client_location.sls_location)
                                                        .for_status(BATCH_OPEN).ordered
        end
        current_size = userset_page_size('binpick_summaries')
        @binpick_bin_summaries = BinpickBinSummary.using(@current_client.cust_no)
                                                  .for_batch(@binpick_batch.id).ordered
        unless session[:filter]['bin_summary_status_filter']
          session[:filter]['bin_summary_status_filter'] = BIN_ASSIGNED
          @filters = session[:filter]
        end
        @binpick_bin_summaries = @binpick_bin_summaries.for_status(filter('bin_summary_status_filter'))
                                                       .filter_by_column(:pick_type, filter('binpick_pick_type_filter'), 'ALL')
                                                       .page(params[:pagesums]).per(current_size)
        @binpick_batch_messages = BinpickBatchMessage.using(@current_client.cust_no)
                                                     .for_batch(@binpick_batch.id).ordered
        @bin_summary_statuses = BinpickBinSummary::STATUS_LIST
        current_size = userset_page_size('binpick_orders')
        @binpick_orders = BinpickOrder.using(@current_client.cust_no)
                                      .for_batch(@binpick_batch.id)
                                      .filter_by_column(:order_seq, filter('binpick_order_seq_filter'), nil)
                                      .filter_by_column(:order_no, filter('binpick_order_no_filter'), nil)
                                      .filter_by_column(:large_order_yn, filter('binpick_size_filter'), 'A')
                                      .filter_by_column(:has_wave_pick_yn, filter('binpick_wave_filter'), 'A')
                                      .filter_by_column(:shipping_status, filter('binpick_shipping_status_filter'), 'ALL')
                                      .ordered.page(params[:pageords]).per(current_size)
        @orders_sizes = BinpickOrder::SIZE_LIST
        @orders_waves = BinpickOrder::WAVE_LIST
        @orders_shipping_statuses = BinpickOrder::STATUS_LIST
        @batch_tab = filter('batch_tabs') == 'ord' ? 'O' : 'B'
        render :show
      else
        clear_filters
        @binpick_batch = get_binpick_batch_not_user
        if @binpick_batch
          flash[:alert] = t('binpick_batch.another_user', emp_no: @binpick_batch.user_no)
          redirect_to root_path and return
        else
          @binpick_batch = BinpickBatch.new(user_id: @current_user.id,
                                            client_id: @current_client.id,
                                            client_location_id: @current_client_location.id,
                                            status: BATCH_NEW)
          @binpick_batch_summaries = BinpickBatchSummary.using(@current_client.cust_no)
                                                        .for_location(@current_client_location.sls_location)
                                                        .for_status(BATCH_NEW).ordered
          @other_binpick_batches = BinpickBatch.pickable.order(:start_order_seq)
          render :new
        end
      end
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path and return
    end
  end

  def other_new
    existing_binpick_batch = get_binpick_batch
    @binpick_batch = BinpickBatch.new(user_id: @current_user.id,
                                      client_id: @current_client.id,
                                      client_location_id: @current_client_location.id,
                                      bo_option: (existing_binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                                                   BinpickBatch::NEWORDERS : BinpickBatch::BACKORDERS,
                                      status: BATCH_NEW)
    @binpick_batch_summaries = BinpickBatchSummary.using(@current_client.cust_no)
                                                  .for_location(@current_client_location.sls_location)
                                                  .for_status(BATCH_NEW).ordered
    @other_binpick_batches = BinpickBatch.pickable.order(:start_order_seq)
    render :new
  end

  def change_batch
    @binpick_batch = get_binpick_batch
    session[:bo_option] = (@binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                            BinpickBatch::NEWORDERS : BinpickBatch::BACKORDERS
    redirect_to binpick_batches_path
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def create # Save text is "Open Binpick Batch"

    if BinpickBatch.using('pg').for_location(@current_client_location).pickable.count > 1
      flash[:alert] = t('binpick_batch.another_batch')
      redirect_to binpick_batches_path and return
    end
    bo_option = params[:binpick_batch][:bo_option] ||= ALL_ORDERS # Deal with possible nil coming from selector
    if BinpickBatch.using('pg').for_location(@current_client_location).pickable.count == 1
      existing_batch = BinpickBatch.using('pg').for_location(@current_client_location).pickable.first
      if BinpickBatch.for_location(@current_client_location).pickable.first.bo_option == ALL_ORDERS || bo_option == ALL_ORDERS
        flash[:alert] = t('binpick_batch.only_one_batch')
        redirect_to binpick_batches_path and return
      end
    end
    batch_row = BinpickBatchSummary.using(@current_client.cust_no).expected_orders(bo_option).first
    expected_orders = batch_row ? batch_row.stat_value : 0
    if expected_orders == 0
      flash[:alert] = t('binpick_batch.no_orders')
      redirect_to binpick_batches_path and return
    end
    start_seq = params[:binpick_batch][:start_order_seq].to_s.to_i
    end_seq = start_seq + expected_orders.to_i - 1
    # puts " start seq = #{start_seq.inspect} end  #{end_seq.inspect} param #{params[:binpick_batch][:start_order_seq]}"
    BinpickBatch.pickable.each do |binpick_batch|
      if start_seq.between?(binpick_batch.start_order_seq, binpick_batch.end_order_seq) ||
        end_seq.between?(binpick_batch.start_order_seq, binpick_batch.end_order_seq) ||
        binpick_batch.start_order_seq.between?(start_seq, end_seq) ||
        binpick_batch.end_order_seq.between?(start_seq, end_seq)
        flash[:alert] = t('binpick_batch.seq_overlaps',
                          { cust_no: binpick_batch.client.cust_no,
                            from: binpick_batch.start_order_seq,
                            to: binpick_batch.end_order_seq })
        redirect_to binpick_batches_path and return
      end
    end

    @binpick_batch = BinpickBatch.new(user_id: @current_user.id, client_id: @current_client.id,
                                      client_location_id: @current_client_location.id,
                                      status: BATCH_CREATING, start_order_seq: params[:binpick_batch][:start_order_seq],
                                      bo_option: bo_option)
    session[:bo_option] = bo_option
    if @binpick_batch.save
      flash[:notice] = t('binpick_batch.created')
      BinpickOracleService.new(@current_client.id, @current_client_location.sls_location, @binpick_batch.id)
                          .delay(run_at: DateTime.now, queue: DelayedJob::PROCESS, client_id: @current_client.id)
                          .make_in_oracle
      session[:filter]['bin_summary_status_filter'] = BIN_ASSIGNED
      @filters = session[:filter]
      redirect_to binpick_batches_path
    else
      flash[:alert] = t('binpick_batch.not_created')
      redirect_to binpick_batches_path
    end
  rescue ActiveRecord::ActiveRecordError => e
    # @binpick_batch.destroy if @binpick_batch.persisted? # don't leave bad batch header out there, messes things up
    flash[:alert] = "Binpick Batch Create process FAILED error = #{e.inspect}"
    puts "*************** Binpick Batch Create process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to root_path and return
  end

  def destroy
    @binpick_batch = get_binpick_batch
    if @binpick_batch.not_deletable?
      flash[:alert] = t('binpick_batch.not_deletable')
      redirect to binpick_batches_path and return
    end
    if @binpick_batch.status != PICKED_COMPLETE
      BinpickBatchProcessor.transaction do
        BinpickBatch.transaction do
          @binpick_batch_processor = BinpickBatchProcessor.using(@current_client.cust_no).new
          @binpick_batch_processor.nds_number = 1
          @binpick_batch_processor.binpick_batch_id = @binpick_batch.id
          @binpick_batch_processor.sls_location = @current_client_location.sls_location # this is sort of overkill since we have the ID, but UVW wants it so whatever
          @binpick_batch_processor.action = BATCH_CANCEL
          @binpick_batch_processor.save
          @binpick_batch.destroy
        end
      end
      flash[:notice] = t('binpick_batch.deleted')
    else
      flash[:alert] = t('binpick_batch.not_deleted')
    end
    redirect_to root_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Batch Destroy process FAILED error = #{e.inspect}"
    puts "*************** Binpick Batch Destroy process FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to root_path and return
  end

  def simultaneously_update_batches(ora_status, pg_status)
    BinpickBatchProcessor.transaction do
      BinpickBatch.transaction do
        @binpick_batch_processor = BinpickBatchProcessor.using(@current_client.cust_no).first
        @binpick_batch_processor.binpick_batch_id = @binpick_batch.id
        @binpick_batch_processor.action = ora_status
        @binpick_batch_processor.save
        @binpick_batch.status = pg_status
        @binpick_batch.pack_complete_at = DateTime.now
        @binpick_batch.save
      end
    end
  rescue ActiveRecord::ActiveRecordError => e
    flash[:alert] = "Binpick Batch Close process FAILED error = #{e.inspect}"
    puts "*************** complete_batch FAILED with #{e.inspect} "
    # raise ActiveRecord::ActiveRecordError
    redirect_to root_path and return
  end

  def packed_complete_batch
    @binpick_batch = get_binpick_batch
    if @binpick_batch.status != PICKED_COMPLETE
      flash[:alert] = t('binpick_batch.not_completed')
    else
      simultaneously_update_batches(BATCH_COMPLETE, BATCH_COMPLETE)
      flash[:notice] = t('binpick_batch.completed')
    end
    redirect_to binpick_batches_path
  end

  def picked_complete_batch
    @binpick_batch = get_binpick_batch
    if BinpickBin.using(@current_client.cust_no).for_batch(@binpick_batch.id).scopen.first
      flash[:alert] = t('binpick_batch.not_completed')
      redirect_to binpick_batches_path and return
    else
      @binpick_batch.status = WAITING_PACK
      @binpick_batch.pack_complete_at = DateTime.now
      @binpick_batch.save
      BinpickOracleService.new(@current_client.id, @current_client_location.sls_location, @binpick_batch.id)
                          .delay(run_at: DateTime.now, queue: DelayedJob::PROCESS, client_id: @current_client.id)
                          .complete_pick_in_oracle
      # simultaneously_update_batches(BATCH_CONFIRMED, PICKED_COMPLETE)
      flash[:notice] = t('binpick_batch.picked')
    end
    redirect_to root_path
  end

  def all_batches
    @batch_statuses = BinpickBatch::STATUS_LIST
    @select_clients = Client.ordered.map { |s| ["#{s.cust_no} #{s.cust_name}", s.id] }.unshift([t(:all), 'A'])
    @select_users = User.where(user_type: 'host').order(:empno).map { |s| ["#{s.empno} #{s.name}", s.id] }.unshift([t(:all), 'A'])
    current_size = userset_page_size('binpick_batches')
    @binpick_batches = BinpickBatch.admin.ordered
                                   .filter_by_column(:status, filter('batch_status_filter'), 'A')
                                   .filter_by_column(:client_id, filter('binpick_batch_client_filter'), 'A')
                                   .filter_by_column(:user_id, filter('binpick_batch_user_filter'), 'A')
                                   .page(params[:page]).per(current_size)
  end

  private

  def get_binpick_batch
    batch = nil
    if session[:bo_option]
      batch = BinpickBatch.where(user_id: current_user.id).
        where(client_id: @current_client.id).
        where(client_location_id: @current_client_location.id).
        pickable.where(bo_option: session[:bo_option]).first
      session[:bo_option] = nil if batch.nil?
    end   
    if batch.nil?
      batch = BinpickBatch.where(user_id: current_user.id).
        where(client_id: @current_client.id).
        where(client_location_id: @current_client_location.id).
        pickable.first
    end
    batch
  end

  def get_binpick_batch_not_user
    return BinpickBatch.where.not(user_id: current_user.id).
      where(client_id: @current_client.id).
      where(client_location_id: @current_client_location.id).
      pickable.first
  end

  def binpick_batch_params
    params.require(:binpick_batch).permit(:start_order_seq, :bo_option)
  end

end
