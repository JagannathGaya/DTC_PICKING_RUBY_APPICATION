class OrdersController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  def index
    if action_permitted?(orders_path, current_user)
      recover_session_order_list
      @orders = Order.using(@current_client.cust_no)
      other_orders = Pick.using('pg').for_client(@current_client.id).where('user_id != ?', current_user.id).pluck(:order_no).join(',')
      @orders = @orders.exclude_orders(other_orders)
      @orders = @orders.ordered
      current_size = userset_page_size('orders')
      @orders = @orders.page(params[:page]).per(current_size)
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  private

  def recover_session_order_list
    orderarray = session[:orderlist] ? session[:orderlist].split(',') : []
    orderarray = orderarray.concat(Pick.using('pg').for_user(current_user.id).for_client(@current_client.id).where(pick_type: 'pick').pluck(:order_no).collect { |n| n.to_s })
    orderarray.compact!
    orderarray.uniq!
    session[:orderlist] = orderarray.join(',')
    logger.debug "SESSION ORDER LIST: #{session[:orderlist]}"
  end

end