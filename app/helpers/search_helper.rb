module SearchHelper

  def search_get_items(area_bin)
    link_to item_locations_path(stock_area: area_bin.split('-')[0], bin_loc: area_bin.split('-')[1]) do
      area_bin
    end
  end

  def search_display_whouse_item(whouse_item)
    link_to whouse_item_path(whouse_item.item_slug) do
      whouse_item.item_no
    end
  end

  def search_display_item(item_location)
    link_to whouse_item_path(item_location.item_slug,:params => {change_client: item_location.ff_schema}) do
      item_location.item_no
    end
  end

  def search_status_color(status_flag)
    (status_flag == 'Active') ? '' : "class=redlight"
  end

  def search_discontinue_color(discontinue_flag)
    (discontinue_flag == 'No') ? '' : "class=redlight"
  end

  def whouse_inv_is_default_class(whouse_inv)
    whouse_inv.is_default == 'Y' ? 'font-weight-bold' : ''
  end

  def search_trans_type_filter
    preselected = session[:filter]['search_trans_type_filter'].split(' ') if session[:filter]['search_trans_type_filter']
    select_tag 'search_trans_type_filter[]',
               options_for_select(ItemTransType.using(@current_client.cust_no).form_lov
                                      .unshift(['All Except Sales Orders', '@'])
                                      .unshift(['All', '?']),
                                  preselected),
               {:multiple => :multiple, :size => 3, style: 'width:230px;'}
  end

  def search_area_bin_filter
    preselected = session[:filter]['search_area_bin_filter'].split(' ') if session[:filter]['search_area_bin_filter']
    select_tag 'search_area_bin_filter[]',
               options_for_select(@area_bins, preselected),
               {:multiple => :multiple, :size => 3}
  end

  def search_qty_mod_filter
    select_tag 'search_qty_mod_filter', options_for_select([[t(:all)], ['>'], ['='], ['<']], session[:filter]['search_qty_mod_filter'])
  end

  def search_loc_type_filter
    select_tag 'search_loc_type_filter',
               options_for_select([['All Locations', 'A'], ['Current Bin Locations', 'C'], ['Past Bin Locations', 'P']],
                                  session[:filter]['search_loc_type_filter'])
  end

  def search_sd_class(item_location)
    (item_location.s_d == 'A/N') ? '' : "class=redlight"
  end

end