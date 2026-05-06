class OptimizeResult
  
  attr_accessor :aisle_num, :entry, :exit, :distance, :cum_distance, :direction, :xdir_lo, :xdir_hi
  
  def initialize(aisle_num)
    @aisle_num = aisle_num
    @entry = 0
    @exit = 0
    @distance = 0
    @cum_distance = 0
    @direction = nil
    @xdir_lo = 0
    @xdir_hi = 0
  end

  def to_s
    "aisle_num = #{self.aisle_num.to_s} \
    entry = #{self.entry.to_s} \
    exit = #{self.exit.to_s} \
    distance = #{self.distance.to_s} \
    cum_distance = #{self.cum_distance.to_s} \
    direction = #{self.direction} \
    xdir_lo = #{self.xdir_lo.to_s} \
    xdir_hi = #{self.xdir_hi.to_s} "
  end

end