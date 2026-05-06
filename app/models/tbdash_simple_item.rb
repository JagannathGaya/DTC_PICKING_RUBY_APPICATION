class TbdashSimpleItem < TbpView

    EXCLUDE_COLUMNS = %w[item_slug]

    self.table_name = 'tbdash_simple_items_vw'
    self.primary_key = 'item_no'

    scope :ordered, -> { order(:item_no) }
    # scope :for_item, -> (filter) { where('item_no like ?',filter.upcase+'%')  unless filter.blank? }
    # scope :for_item_desc, -> (filter) { where('upper(description) like ?',filter.upcase+'%')  unless filter.blank? }
    scope :for_search, -> (filter) { where('item_no like ? or upper(description) like ?',filter.upcase,filter.upcase) unless filter.blank? }

end

# item_no                                   not null varchar2(20)
# item_slug                                 not null varchar2(20)
# description                               not null varchar2(30)
# stock_um                                  not null varchar2(4)
# status_flag                                        varchar2(8)
# discontinue_flag                                   varchar2(3)
# vendor_name                                        varchar2(41)
# current_default_loc                                varchar2(16)
