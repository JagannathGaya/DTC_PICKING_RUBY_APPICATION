class UserValidator

  def initialize(user)
    @user = user
  end

  def validate
    # puts "validating user #{@user.inspect}"
    if @user.user?
      unless @user.client
        @user.errors[:base] << I18n.t('user.must_have_client')
        throw :abort
      end
      if @user.empno
        @user.errors[:base] << I18n.t('user.must_not_have_empno')
        throw :abort
      end
    else
      if @user.client
        @user.errors[:base] << I18n.t('user.must_not_have_client')
        throw :abort
      end
      unless @user.empno
        @user.errors[:base] << I18n.t('user.must_have_empno')
        throw :abort
      end
    end
  end

end