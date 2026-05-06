class PickerController < ApplicationController
  before_action :authorize_host!

  def update
    orderlist = session[:orderlist] || String.new
    orderarray = orderlist.split(',')
    if params[:pick] == 'true'
      orderarray << params[:order_no]
    else
      orderarray.delete params[:order_no]
    end
    session[:orderlist] = orderarray.join(',')
    logger.debug "LIST: #{session[:orderlist]}"
    head :ok
  end


  private

end