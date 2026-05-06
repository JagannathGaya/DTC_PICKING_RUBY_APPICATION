class Admin::UsersController < Admin::HomeController
  before_action :authorize_admin!
  before_action :find_user, only: [:update, :edit, :destroy, :impersonate, :show, :unlock, :pick_release]
  before_action :find_clients, only: [:update, :edit, :new, :create]

  def index
    @select_clients = Client.ordered.pluck(:cust_name, :id).unshift([t(:all), 'A'])
    current_size = userset_page_size('users')
    @users = User.all.ordered.includes(:waves)
                 .filter_by_column(:user_type, filter('user_type_filter'), 'A')
                 .filter_by_column(:client_id, filter('user_client_filter'), 'A')
                 .filter_like_column(:email, filter('user_email_filter'))
                 .filter_like_column(:empno, filter('user_empno_filter'), true)
                 .page(params[:page]).per(current_size).decorate
  end

  def edit
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    if @user.id == current_user.id
      params[:user].delete('user_type')
    end
    if @user.update(user_params)
      flash[:notice] = t('user.updated')
      redirect_to admin_users_path
    else
      flash[:alert] = t('user.not_updated')
      render action: :edit
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_users_path, alert: t('user.conflict')
  end

  def new
    @user = User.new.decorate
    render layout: false
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = t('user.created')
      redirect_to admin_users_path
    else
      flash[:alert] = t('user.not_created')
      @user = @user.decorate
      render :new
    end
  end

  def destroy
    if @user == current_user
      flash[:alert] = t('user.not_yourself')
    else
      @user.destroy
      if @user.errors.count == 0
        flash[:notice] = t('user.deleted')
      else
        flash[:alert] = t('user.not_deleted') + ' ' + @user.errors.full_messages.flatten.join(' ')
      end
    end
    redirect_to admin_users_path
  end

  def impersonate
    return unless current_user.admin?
    bypass_sign_in(@user, scope: :user)
    redirect_to root_url
  end

  def pick_release
    Pick.using('pg').where(user_id: @user.id).delete_all
    Wave.using('pg').where(user_id: @user.id).delete_all
    redirect_to admin_users_path
  end

  def unlock
    @user.unlock_access!
    flash[:notice] = t('user.unlocked')
    redirect_to admin_users_path
  end

  def copy_permit
    @user.add_permits_from_template
  end

  private

  def find_user
    @user = User.find(params[:id].to_i).decorate
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: t('user.not_found')
  end

  def find_clients
    @clients = Client.ordered
  end

  def user_params
    if params[:user][:password].blank?
      params.require(:user).permit(:name, :email, :lock_version,
                                   :current_password, :time_zone, :locale,
                                   :empno, :user_type, :client_id)
    else
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :lock_version,
                                   :current_password, :time_zone, :locale,
                                   :empno, :user_type, :client_id)
    end
  end

end
