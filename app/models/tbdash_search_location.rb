class TbdashSearchLocation < TbpView

  EXCLUDE_COLUMNS = []


  self.table_name = 'tbdash_search_locations_vw'
  self.primary_key = 'area_bin'
  scope :ordered, -> { order(:area_bin)}


end

# stock_area                                         varchar2(4)
# bin_loc                                            varchar2(11)
# area_bin                                           varchar2(16)
