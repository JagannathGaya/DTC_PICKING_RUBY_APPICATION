class WhouseItemsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  def index
    if action_permitted?(whouse_items_path, current_user)
      current_size = userset_page_size('whouse_items')
      @whouse_items = TbdashWhouseItem.using(@current_client.cust_no)
      if filter('whouse_item_no_filter').blank? && filter('whouse_description_filter').blank?
        @whouse_items = @whouse_items.none
      else
        @whouse_items = @whouse_items.filter_like_column('item_no', filter('whouse_item_no_filter'))
                            .filter_column_contains('description', filter('whouse_description_filter'))
      end
      @whouse_items = @whouse_items.ordered.page(params[:page]).per(current_size)
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path and return
    end
  end

  def show
    if !params['change_client'].blank?
      client = Client.using('pg').where("upper(username) = ?", params['change_client'].upcase).first
      client_location = client.client_locations&.first
      @filters ||= {}
      @filters['client_id'] = client.id
      @filters['client_location_id'] = client_location&.id
      session[:filter] = @filters
      # @current_client = client
      set_client
    end
    @whouse_item = TbdashWhouseItem.using(@current_client.cust_no).find(params['id'])
    @whouse_invs = TbdashWhouseInv.using(@current_client.cust_no).where(item_slug: @whouse_item.item_slug).ordered
    current_size = userset_page_size('item_hists', 300)
    @item_hists = TbdashItemHist.using(@current_client.cust_no).where(item_slug: @whouse_item.item_slug).ordered
    @area_bins = @item_hists.map { |h| h.area_bin }.uniq.sort.unshift('ALL')
    if filter('search_trans_type_filter').blank? || filter('search_trans_type_filter') == '@ '
      session[:filter]['search_trans_type_filter'] = '@ '
      @item_hists = @item_hists.where.not(trans_type: 'S')
    else
      unless filter('search_trans_type_filter') == '? '
        @item_hists = @item_hists.filter_column_is_in('trans_type', filter('search_trans_type_filter'))
      end
    end
    unless (filter('search_area_bin_filter').blank? || filter('search_area_bin_filter') == 'ALL ')
      @item_hists = @item_hists.filter_column_is_in('area_bin', filter('search_area_bin_filter'))
    end
    unless (filter('search_loc_type_filter').blank? || filter('search_loc_type_filter') == 'A')
      @item_hists = @item_hists.where(current_loc: 'N') if filter('search_loc_type_filter') == 'P'
      @item_hists = @item_hists.where(current_loc: 'Y') if filter('search_loc_type_filter') == 'C'
    end
    @item_hists = @item_hists.filter_by_specific_qty(:trans_qty,
                                                     filter('search_qty_mod_filter'),
                                                     filter('search_quantity_filter'))
                      .page(params[:page]).per(current_size)
    @batch_tab = filter('batch_tabs') || 'I'
  end

  private


end