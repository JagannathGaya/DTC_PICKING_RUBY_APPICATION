class Bin
  
  attr_accessor :area, :bin_loc, :item_no, :qty, :bin_qty, :bulk_qty, :aisle_num, :rowid, :section, :shelf, :sort_key, :path
  
  def initialize(area=nil, bin_loc=nil, item_no=nil, qty=0, bin_qty=0, bulk_qty=0)
    @area = area
    @bin_loc = bin_loc
    @item_no = item_no
    @qty = qty
    @bin_qty = bin_qty
    @bulk_qty = bulk_qty
    @aisle_num = 0
    @rowid = nil
    @section = 0
    @shelf = nil
    @sort_key = nil
    @path = nil
  end

  def to_s
    "area = #{self.area} \
    bin_loc = #{self.bin_loc} \
    item_no = #{self.item_no} \
    qty = #{self.qty.to_s} \
    bin_qty = #{self.bin_qty.to_s} \
    bulk_qty = #{self.bulk_qty.to_s} \
    aisle_num = #{self.aisle_num} \
    rowid = #{self.rowid} \
    section = #{self.section.to_s} \
    shelf = #{self.shelf}\
    sort_key = #{self.sort_key}\
    path = #{self.path}"
  end

end