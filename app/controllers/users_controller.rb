class UsersController < ApplicationController
  around_action :set_pg_shard
  before_action :authenticate_user!
  before_action :get_user

   def make_api_key
    @user.generate_api_key
    if @user.save!
      redirect_to edit_user_registration_path, notice: t('user.updated')
    else
      redirect_to root_path, alert: t('user.not_updated')
    end
  end

  private

  def get_user
    @user = User.find(params[:user_id].to_i).decorate
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('user.not_found')
  end

end
