class PermitService
  attr_accessor :klass, :method, :user

  def initialize(target, user, method = 'index', client)
    klass = (target.include?('/') ? target.split('/').last : target).camelize + 'Controller'
    @klass = klass.demodulize
    @method = method
    if user.is_a? User
      @user = user
    else
      @user = User.find user
    end
    @client = @user.client || client
    # puts "PermitService user: #{@user.inspect}"
    # puts "PermitService init targets: #{PermitTarget.list}"
    # puts "PermitService init values: #{@klass} #{@method}"
  end

  def allowed?
    report_name = PermitTarget.find(klass, method)
    return true unless report_name
    user_permit = Permit.using('pg').where(report_name: report_name).where(user_id: @user.id).first
    return user_permit.allow if user_permit
    return true unless @client
    client_permit = Permit.using('pg').where(report_name: report_name).where(client_id: @client.id).first
    return client_permit.allow if client_permit
    true
  end

  private


end