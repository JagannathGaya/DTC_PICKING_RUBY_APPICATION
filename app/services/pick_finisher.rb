class PickFinisher

  WAVE_TYPE = 'W'

  def initialize(user, client)
    @user = user
    @connection = client.cust_no
    @wave = Wave.using('pg').for_user(@user.id).for_client(client.id).first
  end

  def write_results
    return true, nil unless @wave
    # Nesting the transaction calls as below causes a rollback of all when any one fails
    # This is a poor solution, but fully distributed transactions are beyond the scope of Active Record.
    begin
      PickWave.using(@connection).transaction do
        PickOrderLine.using(@connection).transaction do
          PickMove.using(@connection).transaction do
            write_moves
            write_order_lines
            signal_complete
          end
        end
      end
    rescue ActiveRecord::StatementInvalid => e
      puts "Oracle returned an error: #{e.inspect}"
      return false, e.inspect
    end
    Pick.using('pg').where(wave_id: @wave.id).delete_all
    @wave.delete
    return true, nil
  end

  private

  def write_moves
    Pick.using('pg').for_wave(@wave.id).where('actual_qty != 0').where(pick_type: 'bulk').order(:item_no).each do |pick|
      PickMove.using(@connection).create(source_id: @wave.id, source_type: WAVE_TYPE, empno: @user.empno, item_no: pick.item_no, qty_moved: pick.actual_qty,
                                                    move_date: Date.today, from_stock_area: pick.pick_area, from_bin_loc: pick.pick_bin,
                                                    to_stock_area: pick.moveto_area, to_bin_loc: pick.moveto_bin)
    end
  end

  def write_order_lines
    Pick.using('pg').for_wave(@wave.id).where('actual_qty != 0').where(pick_type: 'pick').order(:order_no).order(:item_no).each do |pick|
      # puts "writing order line for #{pick.order_no}"
      PickOrderLine.using(@connection).create(wave_id: @wave.id, empno: @user.empno, order_no: pick.order_no, order_suffix: pick.order_suffix,
                                                         line_no: pick.line_no, item_no: pick.item_no, qty_picked: pick.actual_qty,
                                                         stock_area: pick.pick_area, bin_loc: pick.pick_bin, pick_date: Date.today)
    end
  end

  def signal_complete
      PickWave.using(@connection).create(empno: @user.empno, wave_id: @wave.id, pick_date: Date.today)
  end

end