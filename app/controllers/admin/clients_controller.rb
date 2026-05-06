class Admin::ClientsController < Admin::HomeController
  BATCH_RESET = 'R'
  before_action :authorize_admin!
  before_action :get_client, only: [:show, :edit, :update, :destroy, :reset_batches]

  def index
    @clients = Client.ordered
    current_size = userset_page_size('clients')
    @clients = @clients.page(params[:page]).per(current_size)
  end

  def new
    @client = Client.new
    render layout: false
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      flash[:notice] = t('client.created')
      redirect_to admin_clients_path
    else
      flash[:alert] = t('client.not_created')
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    if @client.update(client_params)
      flash[:notice] = t('client.updated')
      redirect_to admin_clients_path
    else
      flash[:alert] = t('client.not_updated')
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_clients_path, alert: t('client.conflict')
  end

  def destroy
    @client.destroy
    if @client.errors.count == 0
      flash[:notice] = t('client.deleted')
    else
      flash[:alert] = t('client.not_deleted') + ' ' + @client.errors.full_messages.flatten.join(' ')
    end
    redirect_to admin_clients_path
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_clients_path, alert: t('client.conflict')
  end

  def reset_batches
    @client.binpick_batches.pickable.each do |batch|
      batch.destroy! # don't see much that will cause this to fail except concurrent update
    end
    @binpick_batch_processor = BinpickBatchProcessor.using(@client.cust_no).new
    @binpick_batch_processor.id = 1
    @binpick_batch_processor.sls_location = @sls_location
    @binpick_batch_processor.action = BATCH_RESET
    if @binpick_batch_processor.save
      flash[:notice] = t('client.batch_reset_complete')
      redirect_to admin_clients_path
    else
      flash[:alert] = t('client.batch_reset_failed')
    end
  end

  private

  def get_client
    @client = Client.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_clients_path, alert: t('client.not_found')
  end

  def client_params
    params.require(:client).permit(:cust_no, :cust_name, :email, :client_manager_email,
                                   :lock_version, :logo, :database, :username, :password, :client_id,
                                   :allow_combined)
  end
end
