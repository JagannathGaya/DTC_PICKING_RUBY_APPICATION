class Admin::BinpickBatchesController < Admin::HomeController

  around_action :set_pg_shard
  before_action :authorize_admin!
  before_action :get_binpick_batch, only: [:edit, :update, :hard_reset]

  BATCH_CANCEL = 'X'
  HARD_RESET = 'R'

  def index
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

  def edit
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    @binpick_batch.user_id = params['binpick_batch']['user_id']
    if @binpick_batch.save
      flash[:notice] = t('binpick_batch.updated')
      redirect_to admin_binpick_batches_path
    else
      flash[:alert] = t('binpick_batch.not_updated')
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_binpick_batches_path, alert: t('binpick_batch.conflict')
  end

  def hard_reset
    BinpickBatchProcessor.transaction do
      BinpickBatch.transaction do
        @binpick_batch_processor = BinpickBatchProcessor.using(@current_client.cust_no).first
        @binpick_batch_processor.binpick_batch_id = @binpick_batch.id
        @binpick_batch_processor.action = HARD_RESET
        @binpick_batch_processor.save
        @binpick_batch.destroy
      end
    end
  flash[:alert] = t('binpick_batch.hard_reset_complete')

  redirect_to admin_binpick_batches_path
rescue ActiveRecord::ActiveRecordError => e
  flash[:alert] = "Binpick Batch Hard Reset process FAILED error = #{e.inspect}"
  puts "*************** Binpick Batch Hard Reset process FAILED with #{e.inspect} "
  rollback
  redirect_to root_path and return
  end

  private

  def get_binpick_batch
    @binpick_batch = BinpickBatch.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_binpick_batches_path, alert: t('binpick_batch.not_found')
  end

  def binpick_batch_params
    params.require(:binpick_batch).permit(:client_id, :user_id, :status, :lock_version)
  end


end
