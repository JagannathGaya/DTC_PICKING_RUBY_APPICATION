class BinpickReplenishmentsController < ApplicationController
  before_action :authorize_host!
  before_action :ensure_minimum_filter

  def index
    if action_permitted?(binpick_replenishments_path, current_user)
      current_size = userset_page_size('binpick_replenishments', 300)
      @binpick_replenishments = BinpickReplenishment.using(@current_client.cust_no).
          ordered.
          page(params[:page]).per(current_size)
    else
      flash[:alert] = t('permit.not_allowed')
      redirect_to root_path
    end
  end

  def move_it
    redirector = params[:redirect_to].partition('?page')[0]
    binpick_replenishment = BinpickReplenishment.using(@current_client.cust_no).find(params['binpick_replenishment_id'].to_i)
    scanner_entry = params['scanner_entry']
    parsed_entry = scanner_entry.split('+')
    prefix = parsed_entry[0]
    stock_area = parsed_entry[1]
    bin_loc = parsed_entry[2]
    if prefix != '.S'
      flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
      render :json => {"new_url" => redirector} and return
    end
    if binpick_replenishment.row_type == BinpickReplenishment::PICK
      if binpick_replenishment.from_stock_area != stock_area || binpick_replenishment.from_bin_loc != bin_loc
        flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
        render :json => {"new_url" => redirector} and return
      end
    end
    if binpick_replenishment.row_type == BinpickReplenishment::PUTAWAY
      if binpick_replenishment.stock_area != stock_area || binpick_replenishment.bin_loc != bin_loc
        flash[:alert] = t('binpick_bin.scan_a_bin', scanned: scanner_entry)
        render :json => {"new_url" => redirector} and return
      end
    end

    binpick_replenishment.empno = current_user.empno
    binpick_replenishment.trans_qty = params['trans_qty']
    binpick_replenishment.action = params['row_type']
    binpick_replenishment.save!
    render :json => {"new_url" => redirector, "error_message" => ""}
  end

  def delete_it
    binpick_replenishment = BinpickReplenishment.using(@current_client.cust_no).find(params['binpick_replenishment_id'].to_i)
    binpick_replenishment.delete
    redirect_to binpick_replenishments_path
  end

  private

end