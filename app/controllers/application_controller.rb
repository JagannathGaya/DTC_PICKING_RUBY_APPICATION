class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :user_time_zone, if: :current_user
  before_action :set_page_size
  before_action :set_client
  #  around_action :wrap_in_rescue

  def action_permitted?(target, user, method = 'index')
    PermitService.new(target, user, method, @current_client).allowed?
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end

  def set_page_size # controller method called from page JS
    session[:pagination_sizes] = {} if session[:pagination_sizes].nil?
    session[:pagination_sizes][self.class.name.downcase.to_sym] = params[:page_size] unless params[:page_size].nil?
  end

  def userset_page_size(recordset, initval = page_size)
    # called when user changes pagesize
    session[:pagesize] ||= {}
    size = (session[:pagesize][recordset] = params[:page_size] ? params[:page_size] : (session[:pagesize][recordset] || initval)).to_i
    size
  end

  def sessionize_filter(value)
    session[:filter][value] = params[value] if params[value]
  end

  def authorize_admin!
    authenticate_user!
    redirect_to root_path, alert: t('admin.must_be_admin') unless current_user.admin?
  end

  def authorize_host!
    authenticate_user!
    redirect_to root_path, alert: t('admin.must_be_host') unless current_user.host?
  end

  def ensure_minimum_filter
    ensure_minimum_admin_filter
    redirect_to root_path, alert: t('client.not_set') unless @current_client
  end

  def ensure_minimum_admin_filter
    session[:filter] ||= {}
  end

  def set_pg_shard(&block)
    Octopus.using('pg', &block)
  end

  def parse_scan(value, type_required)
    return nil if value.blank?
    return value if value.length < 3
    return value if value[0..0] != '.'
    return value[2..-1] if value[1..1] == type_required
    return value
  end

  def clear_filters
    client = session[:filter]['client_id'] if session[:filter]
    client_location = session[:filter]['client_location_id'] if session[:filter]
    session[:filter] = {}
    session[:filter]['client_id'] = client
    session[:filter]['client_location_id'] = client_location
    @filters = session[:filter]
  end

  private

  def wrap_in_rescue
    begin
      puts "in rescued wrap user=#{current_user.inspect} client=#{@current_client.inspect}"
      yield
      puts "in rescued wrap after the yield"
    rescue Exception => e
      puts "in rescued wrap error=#{e.inspect}"
      ErrorMailService.new(e, caller_locations).report
      raise
    end
  end

  def set_client
    if current_user && current_user.user?
      begin
        @current_client = Client.using('pg').find(current_user.client_id)
      rescue ActiveRecord::RecordNotFound
        @current_client = nil
      end
      @current_client_location = nil
    else
      @current_client = Client.using('pg').find(session[:filter]['client_id'].to_i) if session[:filter] && session[:filter]['client_id'] && session[:filter]['client_id'].to_i > 0
      if session[:filter] && session[:filter]['client_location_id'] && session[:filter]['client_location_id'].to_i > 0
        @current_client_location = ClientLocation.using('pg').find(session[:filter]['client_location_id'].to_i)
      else
        @current_client_location = nil
      end
    end
    if @current_client
      logger.debug "++++++ client is now #{@current_client.cust_no}"
      logger.debug "++++++ client location is now #{@current_client_location.sls_location}" if @current_client_location
    else
      logger.debug "++++++ client is NOT set"
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    I18n.locale = current_user.locale if current_user && current_user.locale
    # logger.debug "++++++ locale is now #{I18n.locale}\n"
  end

  def user_time_zone(&block)
    if current_user.time_zone
      Time.use_zone(current_user.time_zone, &block)
    else
      yield
    end
    # logger.debug "++++++ time zone is now #{Time.zone.name}\n"
  end

  def page_size
    # puts "***** #{self.request.env['HTTP_USER_AGENT'].inspect}"
    # Chrome/Win7 agent: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
    # Nexus 7 agent:     "Mozilla/5.0 (Linux; Android 4.4.4; Nexus 7 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.99 Safari/537.36"
    # iPad Mini:         "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
    # iPad:              "Mozilla/5.0 (iPad; CPU OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B511 Safari/9537.53"
    size = (!Rails.env.test? &&
      (self.request.env['HTTP_USER_AGENT'].include?('Android') || self.request.env['HTTP_USER_AGENT'].include?('Mobile'))) ?
             10 : Kaminari.config.default_per_page
    session[:pagination_sizes] = {} if session[:pagination_sizes].nil?
    size = session[:pagination_sizes][self.class.name.downcase.to_sym].to_i unless session[:pagination_sizes][self.class.name.downcase.to_sym].nil?
    size
  end

  def filter(value)
    params[value] || session[:filter][value]
  end

  def unauthorized_domain?(user)
    return false unless user.email.include?(Rails.configuration.intranet_user_email)
    return false if request.original_url.include?(Rails.configuration.intranet_domain)
    true # deny login for local users trying to access from internet
  end

  protected

  def configure_permitted_parameters
    # Devise defaults are: :email, :password, :password_confirmation, :current_password
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation,
                                                                      :current_password, :time_zone, :locale, :empno) }
  end

end
