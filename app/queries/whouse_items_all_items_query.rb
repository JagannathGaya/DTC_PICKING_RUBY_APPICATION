# frozen_string_literal: true

class WhouseItemsAllItemsQuery < ApplicationQuery
  attr_reader :shard, :params, :filters

  def initialize(shard, params, filters = {})
    @shard = shard
    @params = params
    @filters = filters
  end

  def call
    @whouse_items = TbdashWhouseItem.using(shard)
    if filter('whouse_item_no_filter').blank? && filter('whouse_description_filter').blank?
      @whouse_items = @whouse_items.none
    else
      @whouse_items = @whouse_items.filter_like_column('item_no', filter('whouse_item_no_filter'))
                                   .filter_column_contains('description', filter('whouse_description_filter'))
    end
    @whouse_items = @whouse_items.ordered
  end

end