class Admin::ClientLocationsController < Admin::HomeController
  around_action :set_pg_shard
  before_action :authorize_admin!
  before_action :get_client
  before_action :get_client_location, only: [:show, :edit, :update, :destroy]

  def index
    @client_locations = ClientLocation.for_client(@client.id).ordered
  end

  def new
    @client_location = ClientLocation.new(client_id: @client.id)
    render layout: false
  end

  def create
    @client_location = ClientLocation.new(client_location_params)
    if @client_location.save
      flash[:notice] = t('client_location.created')
      redirect_to admin_client_client_locations_path
    else
      flash[:alert] = t('client_location.not_created')
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    if @client_location.update(client_location_params)
      flash[:notice] = t('client_location.updated')
      redirect_to admin_client_client_locations_path
    else
      flash[:alert] = t('client_location.not_updated')
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_client_client_locations_path, alert: t('client_location.conflict')
  end

  def destroy
    if @client.client_locations.count == 1
      flash[:alert] = t('client_location.last_not_deleted')
      else
        @client_location.destroy
        if @client_location.errors.count == 0
          flash[:notice] = t('client_location.deleted')
        else
          flash[:alert] = t('client_location.not_deleted') + ' ' + @client_location.errors.full_messages.flatten.join(' ')
        end
    end
    redirect_to admin_client_client_locations_path
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_client_client_locations_path, alert: t('client_location.conflict')
  end

  private

  def get_client
    @client = Client.find(params[:client_id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_clients_path, alert: t('client.not_found')
  end

  def get_client_location
    @client_location = ClientLocation.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_client_client_locations_path, alert: t('client_location.not_found')
  end

  def client_location_params
    params.require(:client_location).permit(:client_id, :lock_version, :name, :sls_location)
  end
end
