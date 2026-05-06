# frozen_string_literal: true

class AutoMovedItemsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  GEN_ACTION = 'BINPICK_AUTO_REPLENISH'

  def index
    if action_permitted?(auto_moved_items_path, current_user)
      puts "filters = #{session[:filter].inspect}"
      session[:filter]['auto_moved_item_processed_filter'] ||= 'false'
      current_size = userset_page_size('binpick_replenishments')
      @raw_moved_items = AutoMovedItem.using(@current_client.cust_no)
                                       .filter_by_column(:from_stock_area, filter('auto_moved_item_from_stock_area_filter'),'ALL')
      @raw_moved_items = @raw_moved_items.unprocessed unless session[:filter]['auto_moved_item_processed_filter'] == 'true'
      @raw_moved_items = @raw_moved_items.ordered
      @auto_moved_items = @raw_moved_items.page(params[:page]).per(current_size)

      respond_to do |format|
        format.html
        format.csv { send_data @raw_moved_items.to_csv }
        format.xlsx { render xlsx: 'index', filename: "auto_moved_items.xlsx", disposition: 'attachment' }
      end
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  def move_it
    moved = AutoMovedItem.using(@current_client.cust_no).find((params['auto_moved_item_id']).to_i)
    #   puts "moved rec = #{moved.inspect}"
    moved.empno = current_user.empno
    moved.processed_flag = 'Y' # ActiveRecord must detect an actual change to bother with update... empno isn't reliable for this
    moved.save!
    redirect_to auto_moved_items_path
  end

  def generate
    proc = MiscProcessor.using(@current_client.cust_no).new
    proc.nds_number = 1 # Fool activerecord so it doesn't ask with RETURNING clause
    proc.action = GEN_ACTION
    proc.carg1 = current_user.empno
    proc.save!
    redirect_to auto_moved_items_path
  end

  private

end