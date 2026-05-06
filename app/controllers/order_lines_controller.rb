class OrderLinesController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  def index
    if action_permitted?(order_lines_path, current_user)
      @raw_order_lines = OrderLine.using(@current_client.cust_no).for_order_list(session[:orderlist])
      @raw_order_lines = @raw_order_lines.ordered
      current_size = userset_page_size('order_lines')
      @order_lines = @raw_order_lines.page(params[:page]).per(current_size)
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  def start_pick
    if action_permitted?(order_lines_path, current_user)
      pick = PickSequencer.new(session[:orderlist], @current_client, current_user)
      pick.display
      pick.optimize_pick
      pick.display
      redirect_to picks_path
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  private


end
