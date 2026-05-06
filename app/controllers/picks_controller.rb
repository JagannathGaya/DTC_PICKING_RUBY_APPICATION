class PicksController < ApplicationController
  before_action :authorize_host!
  around_action :set_pg_shard
  before_action :ensure_minimum_filter

  def index
    if action_permitted?(picks_path, current_user)
      @picks = Pick.for_user(current_user.id).for_client(@current_client.id)
      @picks = @picks.ordered
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  def update
    if action_permitted?(picks_path, current_user)
      pick = Pick.find(params[:pick_id].to_i)
      LinePickService.new(pick, params).process
      head :ok
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  def finish_pick
    if action_permitted?(picks_path, current_user)
      result, error = PickFinisher.new(current_user, @current_client).write_results
      if result
        session[:orderlist] = String.new
        flash[:notice] = t('pick.finish_pick')
      else
        flash[:alert] = t('pick.oracle_error') + error
        #TODO catch this!
        throw :abort
      end
      redirect_to orders_path
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  private


end