class Admin::PermitsController < Admin::HomeController
  around_action :set_pg_shard
  before_action :authorize_admin!
  before_action :get_permit, only: [:edit, :update, :destroy]

  def index
    @reports = Permit.all.pluck(:report_name).uniq.sort.unshift([t(:all)])
    @clients = Client.ordered.pluck(:cust_no, :id).unshift([t(:all), 0])
    @users = User.permit_users.ordered.pluck(:email, :id).unshift([t(:all), 0])

    @permits = Permit.all
    @permits = @permits.for_report(filter('permit_report_filter')) if filter('permit_report_filter') && filter('permit_report_filter') != t(:all)
    @permits = @permits.for_client(filter('permit_client_filter').to_i) if filter('permit_client_filter') && filter('permit_client_filter') != "0"
    @permits = @permits.for_user(filter('permit_user_filter').to_i) if filter('permit_user_filter') && filter('permit_user_filter') != "0"
    @permits = @permits.ordered
    current_size = userset_page_size('permits')
    @permits = @permits.page(params[:page]).per(current_size)
  end

  def new
    @permit = Permit.new
    render layout: false
  end

  def create
    @permit = Permit.new(permit_params)
    if @permit.save
      flash[:notice] = t('permit.created')
      redirect_to admin_permits_path
    else
      flash[:alert] = t('permit.not_created')
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    if @permit.update(permit_params)
      flash[:notice] = t('permit.updated')
      redirect_to admin_permits_path
    else
      flash[:alert] = t('permit.not_updated')
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_permits_path, alert: t('permit.conflict')
  end

  def destroy
    @permit.destroy
    if @permit.errors.count == 0
      flash[:notice] = t('permit.deleted')
    else
      flash[:alert] = t('permit.not_deleted') + ' ' + @permit.errors.full_messages.flatten.join(' ')
    end
    redirect_to admin_permits_path
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_permits_path, alert: t('permit.conflict')
  end

  private

  def get_permit
    @permit = Permit.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_permits_path, alert: t('permit.not_found')
  end

  def permit_params
    params.require(:permit).permit(:report_name, :client_id, :user_id, :allow, :lock_version)
  end


end
