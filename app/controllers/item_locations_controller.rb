class ItemLocationsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  def new
    if action_permitted?(whouse_items_path, current_user)
      @item_location = ItemLocation.using(@current_client.cust_no).new
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path and return # makes it clearer that no more code should be executed in this method
    end
  end

  def create
    clear_filters
    @item_location = identify_item_location
    if @item_location
      redirect_to item_locations_path(stock_area: @item_location.stock_area, bin_loc: @item_location.bin_loc) and return
    end
    redirect_to new_item_location_path
  end

  def index
    @stock_area = params[:stock_area]
    @bin_loc = params[:bin_loc]
    current_size = userset_page_size('item_locations', 50)
    @item_locations = ItemLocation.using(@current_client.cust_no).where(stock_area: @stock_area).where(bin_loc: @bin_loc)
    @item_locations = @item_locations.ordered.page(params[:page]).per(current_size)
  end

  private

  def identify_item_location
    if !params[:item_location][:stock_area].blank? && !params[:item_location][:bin_loc].blank?
      item_location = ItemLocation.using(@current_client.cust_no).new
      item_location.stock_area = params[:item_location][:stock_area].upcase
      item_location.bin_loc = params[:item_location][:bin_loc].upcase
      return item_location
    end
    scanner_entry = params[:item_location][:description] # hijacked 30 chr field for scanner entry
    parsed_entry = scanner_entry.split('+')
    prefix = parsed_entry[0]
    stock_area = parsed_entry[1]
    bin_loc = parsed_entry[2]
    if prefix != '.S'
      flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
      return
    end
    item_location = ItemLocation.using(@current_client.cust_no).new
    item_location.stock_area = stock_area.upcase
    item_location.bin_loc = bin_loc.upcase
    item_location
  end


end