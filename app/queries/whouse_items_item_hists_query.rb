# frozen_string_literal: true

class WhouseItemsItemHistsQuery < ApplicationQuery
  attr_reader :shard, :params, :filters, :slug

  def initialize(shard, params, filters = {}, slug)
    @shard = shard
    @params = params
    @filters = filters
    @slug = slug
  end

  def call
    @item_hists = TbdashItemHist.using(shard).where(item_slug: slug).ordered
    if filter('search_trans_type_filter').blank? || filter('search_trans_type_filter') == '@ '
      filters['search_trans_type_filter'] = '@ '
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
  end

end