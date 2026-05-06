class BinpickOrdersController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter


  def destroy
    @binpick_order = BinpickOrder.using(@current_client.cust_no).find(params[:id])
    @binpick_order.destroy
    if @binpick_order.errors.count == 0
      flash[:notice] = t('binpick_order.deleted')
    else
      flash[:alert] = t('binpick_order.not_deleted') + ' ' + @binpick_order.errors.full_messages.flatten.join(' ')
    end
    redirect_to binpick_batches_path
  end


  private

end
