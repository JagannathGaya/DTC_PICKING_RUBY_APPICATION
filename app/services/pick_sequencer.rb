class PickSequencer
  AISLE_MAX = 20
  attr_accessor :bins, :shortbins, :results

  def initialize(orderlist, client, user)
    @user = user
    @client = client
    @connection = client.cust_no
    @orders = orderlist.split(',')
    @orderlines = OrderLine.using(@connection).for_order_list(orderlist).ordered
    @bins = get_bin_list
    @shortbins = get_short_bins
    @seqbins = get_seq_bins
    @areas = @seqbins.collect { |s| s.area }.uniq
    @tb_aisle_rows = TbAisleRow.using(@connection).all.ordered
    @results = []
    (1..AISLE_MAX).each do |aisle_num|
      @results[aisle_num] = OptimizeResult.new(aisle_num)
    end
    pre_process
  end

  def optimize_pick
    @best_distance = 0
    @areas.each do |area|
      tb_area_struct = TbAreaStruct.using(@connection).where(stock_area: area).first
      t_aisle_num = @seqbins.min { |a, b| a.aisle_num <=> b.aisle_num }.aisle_num
      @best_distance = optimize_aisle(tb_area_struct, t_aisle_num, 0, 1, 0)
      record_results(tb_area_struct)
    end
    post_process
  end

  def display
    @bins.each { |bin| puts "BIN SUMMARY: #{bin.to_s}\n" }
    @shortbins.each { |bin| puts "SHORT BINS:  #{bin.to_s}\n" }
    @seqbins.each { |bin| puts "BINS TO SEQUENCE:  #{bin.to_s}\n" }
    @areas.each { |area| puts "AREAS: #{area}\n" }
    @results.each { |result| puts "RESULTS:  #{result.to_s}\n" }
  end

  private

  def post_process
    wave = create_wave
    # For each short bin, write a resupply record
    write_replenishments
    # for each row in orderlines, write a pick record, using the sortkey and path from seqbins
    write_order_picks
    # Get rid of empty waves
    Wave.using('pg').where(id: wave.id).delete_all unless Pick.using('pg').exists?(wave_id: wave.id)
  end

  def create_wave
    @wave = Wave.using('pg').create!(user_id: @user.id, client_id: @client.id, order_list: @orders.join(','))
  end

  def write_replenishments
    @shortbins.each do |bin|
      bulk_stock_loc = BulkStockLoc.using(@connection).where(item_no: bin.item_no).first
      if bulk_stock_loc
        pick = Pick.using('pg').create!(wave_id: @wave.id, client_id: @client.id, user_id: @user.id, pick_type: 'bulk', action_seq: 'A',
                                        sort_key: '%s00000%s' % [bulk_stock_loc.stock_area + '0' * (4 - bulk_stock_loc.stock_area.length), bulk_stock_loc.bin_loc],
                                        moveto_area: bin.area, moveto_bin: bin.bin_loc,
                                        item_no: bin.item_no, pick_area: bulk_stock_loc.stock_area, pick_bin: bulk_stock_loc.bin_loc, pick_qty: bin.qty - bin.bin_qty)
        dropbin = @bins.detect(Bin.new) { |dropbin| dropbin.item_no == bin.item_no }
        sort_key = dropbin.sort_key || '%s00000%s' % [dropbin.area + '0' * (4 - dropbin.area.length), dropbin.bin_loc]
        place = Pick.using('pg').create!(wave_id: @wave.id, client_id: @client.id, user_id: @user.id, pick_type: 'drop', action_seq: 'B',
                                         sort_key: sort_key, path: dropbin.path,
                                         item_no: bin.item_no, pick_area: bin.area, pick_bin: bin.bin_loc, pick_qty: bin.qty - bin.bin_qty)
      end
    end
  end

  def write_order_picks
    @orderlines.each do |orderline|
      seqbin = if @seqbins.empty?
                 Bin.new
               else
                 @seqbins.detect(Bin.new) { |bin| bin.item_no == orderline.item_no }
               end
      if seqbin.sort_key
        action_seq = 'B'
      else
        action_seq = 'C'
        seqbin.sort_key = '%s00000%s' % [orderline.stock_area + '0' * (4 - orderline.stock_area.length), orderline.bin_loc]
      end
      pick = Pick.using('pg').create!(wave_id: @wave.id, client_id: @client.id, user_id: @user.id,
                                      pick_type: 'pick', sort_key: seqbin.sort_key, path: seqbin.path,
                                      action_seq: 'B', item_no: orderline.item_no, pick_area: orderline.stock_area,
                                      pick_bin: orderline.bin_loc, pick_qty: orderline.qty_order,
                                      order_no: orderline.order_no, order_suffix: orderline.order_suffix, line_no: orderline.line_no)
    end
  end

  def optimize_aisle(tb_area_struct, aisle_num, prev_aisle_num, entry_in, distance)
    return 0 if @seqbins.empty?
    return 0 unless tb_area_struct
    tb_aisle = TbAisle.using(@connection).for_area(tb_area_struct.stock_area).for_aisle_num(aisle_num).first
    return 0 unless tb_aisle
    t_save_results = OptimizeResult.new(aisle_num)
    section_min = @seqbins.min { |a, b| a.section <=> b.section }.section.to_i
    section_max = @seqbins.max { |a, b| a.section <=> b.section }.section.to_i
    t_this_direction = tb_aisle.pref_direction
    t_entry = entry_in
    t_idle_distance = 0
    t_aisle_distance = 0
    t_cum_distance = distance
    t_min_distance = 99999
    t_min_aisle_distance = 0
    t_min_direction = tb_aisle.pref_direction
    t_next_aisle = 0
    t_back_distance1 = 0
    t_back_distance2 = 0
    t_min_xdir_lo = 0
    t_min_xdir_hi = 0
    t_exit = 0
    exit_cur = []
    # This is to exclude impractical shortcuts to entry
    if (tb_aisle.pref_direction == 'A' && (section_min - t_entry) < (0 - tb_area_struct.xdir_sections)) ||
        (tb_aisle.pref_direction == 'D' && (section_max - t_entry) > tb_area_struct.xdir_sections) ||
        ((section_min - t_entry) < (0 - tb_area_struct.xdir_sections.to_i) && (section_max - t_entry) > tb_area_struct.xdir_sections.to_i)
      # If the exit being tested is an endpoint, we cannot reject it, must force it in the right direction....
      # Entry point swap is also valid when previous exit was a shortcut and intervening aisle exists
      unless [tb_area_struct.sec_range_lo, tb_area_struct.sec_range_hi].include? t_entry && aisle_num == prev_aisle_num + 1
        Rails.logger.debug "optimize_aisle Cannot reach bins from entry point."
        return 0
      else
        # force entry point swap
        t_entry = tb_aisle.pref_direction == 'A' ? tb_area_struct.sec_range_lo : tb_area_struct.sec_range_hi
        # add the penalty for swapping entry points
        t_idle_distance = (t_entry - entry_in).abs + 1
      end
    end
    other_aisles_bins = @seqbins.find_all { |bin| bin.aisle_num > aisle_num }.uniq
    t_next_aisle = other_aisles_bins.empty? ? 999 : other_aisles_bins.collect { |bin| bin.aisle_num }.min
    if t_next_aisle == 999
      case tb_aisle.pref_direction
        when 'A'
          t_aisle_distance = t_idle_distance + tb_area_struct.sec_range_hi - t_entry + 1
          t_min_exit = tb_area_struct.sec_range_hi
        when 'D'
          t_aisle_distance = t_idle_distance + t_entry - tb_area_struct.sec_range_lo + 1
          t_min_exit = tb_area_struct.sec_range_lo
        else
          t_this_direction = 'D'
          t_aisle_distance = ([t_entry - section_min, t_entry - section_max].min).abs + 1
      end
      t_cum_distance = t_aisle_distance
      t_min_distance = t_aisle_distance
      t_min_aisle_distance = t_aisle_distance
      t_min_direction = t_this_direction
    else # more stuff to do, t_next_aisle != 999
      tb_area_shortcut = TbAreaShortcut.using(@connection).where(stock_area: tb_area_struct.stock_area).first
      shortcut = tb_area_shortcut.shortcut if tb_area_shortcut
      exit_cur << shortcut if shortcut &&
          ((tb_aisle.pref_direction == 'A' && (shortcut + tb_area_struct.xdir_sections) > section_max) ||
              (tb_aisle.pref_direction == 'D' && (shortcut - tb_area_struct.xdir_sections) < section_min) ||
              (((shortcut + tb_area_struct.xdir_sections) > section_max || t_entry >= section_max) &&
                  (((shortcut - tb_area_struct.xdir_sections)) < section_min || t_entry <= section_min)))
      exit_cur << tb_area_struct.sec_range_lo if ['N', 'D'].include? tb_aisle.pref_direction ||
                                                                         tb_area_struct.sec_range_lo - section_min < tb_area_struct.xdir_sections
      exit_cur << tb_area_struct.sec_range_hi if ['N', 'A'].include? tb_aisle.pref_direction ||
                                                                         tb_area_struct.sec_range_hi - section_max < tb_area_struct.xdir_sections
      exit_cur.each do |exit_section|
        t_back_distance1 = 2 * [[t_entry, t_exit].min - section_min, 0].max
        t_back_distance2 = 2 * [section_max -[t_exit, t_entry].max, 0].max
        t_aisle_distance = (t_entry - exit_section).abs + t_back_distance1 + t_back_distance2
        t_this_direction = case
                             when t_entry < t_exit
                               'A'
                             when t_entry > t_exit
                               'D'
                           end if tb_aisle.pref_direction == 'N'
        t_next_distance = optimize_aisle(tb_area_struct, t_next_aisle, aisle_num, exit_section, t_cum_distance)
        unless t_next_distance == 0
          t_this_distance = t_idle_distance + t_aisle_distance + t_next_distance
          if t_this_distance < t_min_distance
            t_min_distance = t_this_distance
            t_min_aisle_distance = t_aisle_distance + t_idle_distance
            t_min_exit = exit_section
            t_min_direction = t_this_direction
            t_min_xdir_lo = t_back_distance1 > 0 ? section_min : 0
            t_min_xdir_hi = t_back_distance2 > 0 ? section_max : 0
            t_save_results = @results[aisle_num]
          end
        end

      end
      t_cum_distance = t_min_distance
    end
    @results[aisle_num] = t_save_results
    @results[aisle_num].distance = t_min_aisle_distance
    @results[aisle_num].cum_distance = t_min_distance
    @results[aisle_num].exit = t_min_exit
    @results[aisle_num].direction = t_min_direction
    @results[aisle_num].xdir_lo = t_min_xdir_lo
    @results[aisle_num].xdir_hi = t_min_xdir_hi
    @results[aisle_num].entry = t_entry

    t_cum_distance
  end

  def record_results(tb_area_struct)
    t_bin_order = nil
    t_aisle = nil
    t_direction = nil
    t_first_rowid = nil
    t_last_rowid = nil
    t_path = nil
    @results.each do |res|
      if res && res.entry > 0
        aisle_num = res.aisle_num
        t_bin_order = 0
        t_aisle = aisle_num
        t_direction = @results[aisle_num].direction
        t_first_rowid = nil
        @seqbins.sort! { |a, b| compare_bins(a, b, t_direction) }
        @seqbins.each do |bin|
          t_first_rowid ||= bin.rowid
          t_last_rowid = bin.rowid
          t_bin_order += 1
          bin.sort_key = '%s%02d%03d%s%s' % [tb_area_struct.stock_area + '0' * (4 - tb_area_struct.stock_area.length), aisle_num, t_bin_order, bin.rowid, bin.shelf]
          bin.path = t_direction == 'A' ? '^' : 'v'
        end
        if t_first_rowid == t_last_rowid # endpoints are the same case, need to merge xdir results
          if @results[aisle_num].xdir_lo > 0 || @results[aisle_num].xdir_hi > 0
            if t_direction == 'A'
              t_path = @results[aisle_num].exit >= [@results[aisle_num].xdir_lo, @results[aisle_num].xdir_hi].max ? '^' : 'v'
            else
              t_path = @results[aisle_num].exit <= [@results[aisle_num].xdir_lo, @results[aisle_num].xdir_hi].max ? 'V' : '^'
            end
          else
            t_path = t_direction == 'A' ? '^' : 'v'
          end
          # tack on shortcut if required
          t_path ||= '%03d' % @results[aisle_num].exit unless [tb_area_struct.sec_range_lo, tb_area_struct.sec_range_hi].include? @results[aisle_num].exit
          @seqbins[@seqbins.find_index { |b| b.rowid == t_first_rowid }].path = t_path
        else # different start and end points
          # deal with starting point
          if t_direction == 'A'
            t_path = @results[aisle_num].xdir_lo > 0 && @results[aisle_num].exit <= @results[aisle_num].xdir_lo ? 'v' : '^'
          else
            t_path = @results[aisle_num].xdir_hi > 0 && @results[aisle_num].exit >= @results[aisle_num].xdir_hi ? '^' : 'v'
          end
          @seqbins[@seqbins.find_index { |b| b.rowid == t_first_rowid }].path = t_path
          # deal with exit point
          if t_direction == 'A'
            t_path = @results[aisle_num].xdir_hi > 0 ? 'v' : '^'
          else
            t_path = @results[aisle_num].xdir_lo > 0 ? '^' : 'v'
          end
          # tack on shortcut if required
          t_path ||= '%03d' % @results[aisle_num].exit unless [tb_area_struct.sec_range_lo, tb_area_struct.sec_range_hi].include? @results[aisle_num].exit
          @seqbins[@seqbins.find_index { |b| b.rowid == t_last_rowid }].path = t_path
        end # test endpoints
      end # something in aisle loop
    end
  end

  def compare_bins(bina, binb, dir)
    if dir == 'A'
      return -1 if bina.section < binb.section
      return 1 if bina.section > binb.section
    else
      return 1 if bina.section < binb.section
      return -1 if bina.section > binb.section
    end
    return -1 if bina.rowid < binb.rowid
    return 1 if bina.rowid > binb.rowid
    return -1 if bina.shelf < binb.shelf
    return 1 if bina.shelf > binb.shelf
    0
  end

  def pre_process
    @seqbins.each do |bin|
      ix = @tb_aisle_rows.find_index { |a| a.stock_area == bin.area && a.row_id == bin.bin_loc.first }
      bin.aisle_num = @tb_aisle_rows[ix].aisle_num if ix
      bin.rowid = bin.bin_loc.first
      bin.section = bin.bin_loc[1, 3]
      bin.shelf = bin.bin_loc[4]
    end
    # Clean out the holding pen
    @user.picks.delete_all
  end

  def get_bin_list
    bins = []
    @orderlines.each do |line|
      ix = bins.find_index { |bin| bin.area == line.stock_area && bin.bin_loc == line.bin_loc && bin.item_no == line.item_no }
      if ix
        bins[ix].qty += line.qty_order
      else
        bins << Bin.new(line.stock_area, line.bin_loc, line.item_no, line.qty_order, line.def_on_hand, line.other_on_hand)
      end
    end
    bins
  end

  def get_short_bins
    @bins.find_all { |bin| bin.qty > bin.bin_qty }
  end

  def get_seq_bins
    bins = TbAisle.using(@connection).pluck(:stock_area).uniq
    @bins.find_all { |bin| bins.include? bin.area }
  end

end