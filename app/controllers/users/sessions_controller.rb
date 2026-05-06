class Users::SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    if !params['user']['empno'].blank?
      empno = parse_scan(params['user']['empno'].upcase, 'U')
      puts "EMPNO #{empno}"
      self.resource = User.host_users.where(empno: empno.upcase).first
      if !params['user']['client_id'].blank?
        client = Client.using('pg').find(params['user']['client_id'])
        @filters ||= {}
        @filters['client_id'] = client.id
        session[:filter] = @filters
        @current_client = client
      end
    end
    self.resource = warden.authenticate!(auth_options) unless self.resource
    set_flash_message!(:notice, :signed_in)
    puts "USER IS #{self.resource.inspect}"
    sign_in(resource_name, self.resource)
    yield self.resource if block_given?
    respond_with self.resource, location: after_sign_in_path_for(self.resource)
  end

  protected

  def after_sign_in_path_for(resource)
    # puts "after_sign_in resource = #{resource.inspect}"
    if resource.is_a?(User) && unauthorized_domain?(resource)
      flash.delete(:notice)
      set_flash_message!(:error, :intranet_user_denied)
      sign_out resource
      new_user_session_path
    else
      if resource.host? && session[:filter].present? && session[:filter]['client_location_id'].present?
        open_batch = BinpickBatch.for_location(session[:filter]['client_location_id'].to_i).pickable.first
        if open_batch
          new_binpick_bin_path
        else
          super
        end
      else
        super
      end
    end
  end

end
