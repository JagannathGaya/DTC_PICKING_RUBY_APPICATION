module BinpickHelper

  def edit_binpick_batch_link(binpick_batch)
    if %W(I O P K).include? binpick_batch.status
      link_to binpick_batch.id, edit_admin_binpick_batch_path(binpick_batch),
              data: { colorbox: true, colorbox_width: 700, colorbox_height: 340 }
    else
      binpick_batch.id
    end
  end

  def packed_complete_binpick_batch(binpick_batch)
    return unless binpick_batch
    return unless binpick_batch.status == 'K'
    return if binpick_batch.status == 'B'
    return if binpick_batch.status == 'W'
    css_class = 'btn btn-sm btn-primary disabled'
    link_to binpick_batch_packed_complete_batch_path(binpick_batch), method: :put,
            data: { confirm: t('binpick_batch.confirm_complete') },
            class: css_class, id: 'binpick_batch_complete_button' do
      icon('save') + t('binpick_batch.complete')
    end
  end

  def picked_complete_binpick_batch(binpick_batch)
    return unless binpick_batch
    return if binpick_batch.status == 'K'
    return if binpick_batch.status == 'B'
    return if binpick_batch.status == 'W'
    return if BinpickBin.using(@current_client.cust_no).for_batch(binpick_batch.id)
                        .scopen.first
    return if binpick_batch.status == 'O' &&
      BinpickOrder.using(@current_client.cust_no).for_batch(binpick_batch.id)
                  .where(shipping_status: 'INVALID').first
    css_class = 'btn btn-sm btn-primary'
    link_to binpick_batch_picked_complete_batch_path(binpick_batch), method: :put,
            data: { confirm: t('binpick_batch.confirm_picked') },
            class: css_class, id: 'binpick_batch_complete_button' do
      icon('save') + t('binpick_batch.picked')
    end
  end

  def picker_says_picked_complete_binpick_batch(binpick_batch)
    return unless binpick_batch
    css_class = 'btn btn-sm btn-primary'
    link_to binpick_batch_picked_complete_batch_path(binpick_batch), method: :put,
            data: { confirm: t('binpick_batch.confirm_picked') },
            class: css_class, id: 'binpick_batch_complete_button' do
      icon('save') + t('binpick_batch.picked')
    end
  end

  def nearly_complete_binpick_batch(binpick_batch)
    return unless binpick_batch
    if BinpickBin.using(@current_client.cust_no).for_batch(binpick_batch.id).scopen.first
      check_box_tag("binpick_batch_complete_cb", "binpick_batch_complete_cb", false, disabled: true)
    else
      check_box_tag("binpick_batch_complete_cb", "binpick_batch_complete_cb", false)
    end
  end

  def pick_binpick_batch(binpick_batch)
    return unless binpick_batch
    return if binpick_batch.status == 'K'
    return if binpick_batch.status == 'B'
    return if binpick_batch.status == 'W'
    link_to new_binpick_bin_path, class: 'btn btn-sm btn-primary' do
      icon('dolly') + t('binpick_batch.pick')
    end
  end

  def start_another_batch(binpick_batch)
    return unless binpick_batch
    # return if binpick_batch.status == 'K'  # LJK these conditions should not preclude manager from starting another batch
    #return if binpick_batch.status == 'W'
    return if binpick_batch.bo_option == 'A'
    return if BinpickBatch.for_location(@current_client_location).pickable.count > 1
    link_to binpick_batch_other_new_path(binpick_batch), method: :put,
            class: 'btn btn-sm btn-primary', id: 'binpick_batch_other_new_button' do
      icon('plus') + t('binpick_batch.other_new',
                       bo_option: (binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                                    t("binpick_batch.bo_option_list.#{BinpickBatch::NEWORDERS}") :
                                    t("binpick_batch.bo_option_list.#{BinpickBatch::BACKORDERS}"))
    end
  end

  def manage_other_batch(binpick_batch)
    return unless BinpickBatch.for_location(@current_client_location).pickable.count > 1 # LJK this is sufficient for manager to be able to switch to other batch
    other_batch = BinpickBatch.using('pg')
                              .where(user_id: current_user.id)
                              .where(client_id: @current_client.id)
                              .where(client_location_id: @current_client_location.id)
                              .pickable.where.not(bo_option: binpick_batch.bo_option).first
    return unless other_batch&.is_pickable?
    link_to binpick_batch_change_batch_path(binpick_batch),
            class: 'btn btn-sm btn-primary', id: 'binpick_batch_change_batch_button' do
      t('binpick_batch.change_batch',
        bo_option: (binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                     t("binpick_batch.bo_option_list.#{BinpickBatch::NEWORDERS}") :
                     t("binpick_batch.bo_option_list.#{BinpickBatch::BACKORDERS}"))
    end

  end

  def change_to_other_batch(binpick_batch)
    return unless BinpickBatch.using('pg').for_location(@current_client_location).pickable.count > 1
    other_batch = BinpickBatch.using('pg') #       .where(user_id: current_user.id)   LJK not sure why this is here
                              .where(client_id: @current_client.id)
                              .where(client_location_id: @current_client_location.id)
                              .pickable.where.not(bo_option: binpick_batch.bo_option).first
    return unless other_batch&.is_open?
    link_to binpick_bin_change_batch_path(binpick_batch), method: :put,
            class: 'btn btn-sm btn-primary', id: 'binpick_bin_other_new_button' do
      icon('plus') + t('binpick_bin.other_batch',
                       bo_option: (binpick_batch.bo_option == BinpickBatch::BACKORDERS) ?
                                    t("binpick_batch.bo_option_list.#{BinpickBatch::NEWORDERS}") :
                                    t("binpick_batch.bo_option_list.#{BinpickBatch::BACKORDERS}"))
    end

  end

  def delete_binpick_batch(binpick_batch)
    return unless binpick_batch
    return if binpick_batch.status == 'K'
    link_to binpick_batch_path(binpick_batch), method: :delete,
            data: { confirm: t('binpick_batch.confirm_delete') },
            class: 'btn btn-sm btn-primary' do
      icon('trash') + t('binpick_batch.delete')
    end
  end

  def binpick_bin_item_backorder(binpick_bin_item, binpick_bin)
    puts "#binpick_bin_item_backorder binpick_bin_item = #{binpick_bin_item.inspect} all_orders = #{binpick_bin.pick_all_orders?}"
    return unless binpick_bin_item
    if binpick_bin.pick_all_orders?
      link_to binpick_bin_item_autopick_all_orders_path(binpick_bin_item.id.to_i),
              method: :put, class: 'btn btn-sm btn-primary' do
        icon('save') + t('binpick_bin.autopick')
      end
    else
      link_to binpick_bin_item_bin_item_backorder_path(binpick_bin_item.id.to_i),
              method: :put, data: { confirm: t('binpick_bin.confirm_backorder') },
              class: 'btn btn-sm btn-primary' do
        icon('save') + t('binpick_bin.backorder')
      end
    end
  end

  def binpick_all_orders_backorder(binpick_bin_item, exceptions_present=false)
    puts "#binpick_all_orders_backorder, exceptions_present = #{exceptions_present}"
    return unless binpick_bin_item
    link_to edit_binpick_bin_item_path(binpick_bin_item.id.to_i, params: {exceptions_present: exceptions_present}),
            data: { colorbox: true },
            class: 'btn btn-sm btn-primary' do
      icon("empty.png") + t('binpick_bin.shortage')   # TODO: Icon isn't working here
    end
  end

  def binpick_bin_item_reverse_backorder(binpick_bin_item)
    return unless binpick_bin_item
    link_to binpick_bin_item_bin_item_bo_reverse_path(binpick_bin_item.id.to_i),
            method: :put, data: { confirm: t('binpick_bin.confirm_bo_reverse') },
            class: 'btn btn-sm btn-primary' do
      icon('save') + t('binpick_bin.bo_reverse')
    end
  end

  def binpick_bin_confirm_order_line(order_line, firstrow)
    return unless order_line.action == 'N'
    style = (firstrow && order_line.action == 'N') ? "padding: 35% 0;" : ""
    button_class = "btn btn-md btn-block"
    button_class += order_line.large_order_yn == 'Y' ? " btn-success" : " btn-primary"
    link_to binpick_order_line_confirm_path(order_line.id.to_i), method: :put, class: button_class, style: style do
      icon('check') +
        "<span class='#{style.blank? ? 'h3' : 'binpick_big_font' }'>#{order_line.order_seq.to_i.to_s}</span>".to_s.html_safe
    end
  end

  def binpick_wave_confirm_order_line(order_line, firstrow)
    return unless order_line.action == 'N'
    label = "#{order_line.order_seq.to_i.to_s} - #{order_line.line_no}"
    style = (firstrow && order_line.action == 'N') ? "padding: 35% 0;" : ""
    button_class = "btn btn-md btn-block"
    button_class += order_line.large_order_yn == 'Y' ? " btn-success" : " btn-primary"
    link_to binpick_wave_line_confirm_path(order_line.id.to_i), method: :put, class: button_class, style: style do
      icon('check') +
        "<span class='#{style.blank? ? 'h3' : 'binpick_big_font' }'>#{label}</span>".to_s.html_safe
    end
  end


  def auto_moved_item_processed_filter
    #   puts "auto_moved_item_processed_filter filters = #{session[:filter].inspect}"
    val = session[:filter]['auto_moved_item_processed_filter'] == 'true' ? true : false
    "<div class='form-check'>
    <input class='form-check-input filter_checkbox' type='checkbox'  id='auto_moved_item_processed_filter' #{val ? 'checked=true' : ''} >
    <label class'form-check-label' for='auto_moved_item_processed_filter' >
      #{I18n.t('auto_moved_item.include_processed')}
    </label>
    </div>".to_s.html_safe
  end

  def generate_auto_moves_button
    link_to auto_moved_items_path, method: :post,
            data: { confirm: t('auto_moved_item.confirm_generate') },
            class: 'btn btn-sm btn-primary' do
      icon('lightning') + t('auto_moved_item.generate_button')
    end
  end

  def confirm_auto_moved_item(moved_item)
    return if moved_item.nil? || moved_item.processed_flag == 'Y'
    button_class = "btn btn-md btn-block btn-primary binpick_med_font"
    link_to auto_moved_item_move_it_path(moved_item.id.to_i), method: :put, class: button_class do
      icon('check') +  I18n.t('auto_moved_item.done')
    end
  end

  def order_line_qty(order_line)
    if order_line.qty_shipped == 1
      formatted_qty(order_line.qty_shipped)
    else
      "<span class='binpick_big_font bg-warning'>#{formatted_qty(order_line.qty_shipped)}</span>".to_s.html_safe
    end
  end

  def wave_line_qty(order_line)
    if order_line.qty_shipped == 1
      formatted_qty(order_line.qty_shipped)
    else
      "<span class='bg-warning h3'>#{formatted_qty(order_line.qty_shipped)}</span>".to_s.html_safe
    end
  end

  def order_line_qty_td(order_line)
    if order_line.qty_shipped == 1
      "class='align-middle h3'".to_s.html_safe
    else
      "class='bg-warning align-middle'".to_s.html_safe
    end
  end

  def binpick_bin_unconfirm_order_line(order_line, firstrow)
    return unless ['S','B'].include?(order_line.action)
    button_class = "btn btn-md"
    button_class += order_line.large_order_yn == 'Y' ? " btn-success" : " btn-primary"
    link_to binpick_order_line_unconfirm_path(order_line.id.to_i), method: :put, class: button_class do
      icon('times') + "<span class='h3'>    #{order_line.order_seq.to_i.to_s}</span>".to_s.html_safe
    end
  end

  def binpick_wave_unconfirm_order_line(order_line, firstrow)
    return unless ['S','B'].include?(order_line.action)
    label = "#{order_line.order_seq.to_i.to_s} - #{order_line.line_no}"
    button_class = "btn btn-md"
    button_class += order_line.large_order_yn == 'Y' ? " btn-success" : " btn-primary"
    link_to binpick_wave_line_unconfirm_path(order_line.id.to_i, params: {redirect_to: binpick_wave_picks_path(order_line.binpick_batch_id.to_i)}), method: :put, class: button_class do
      icon('times') + "<span class='h3'>    #{label}</span>".to_s.html_safe
    end
  end


  def binpick_wave_line_backorder(order_line)
    return    "<span class='h3'>    #{order_line.message}</span>".to_s.html_safe if order_line.backordered?
    return unless order_line.action == 'N'
    button_class = "btn btn-md"
    button_class += order_line.large_order_yn == 'Y' ? " btn-success" : " btn-primary"
    link_to binpick_wave_line_backorder_path(order_line.id.to_i), method: :put, class: button_class do
      "<span class='h3'>    #{t('binpick_order_line.backorder_line')}</span>".to_s.html_safe
    end
  end

  def binpick_tr_class(order_line, firstrow)
    html_class = (firstrow && order_line.action == 'N') ? "giantrow" : "fatrow"
    html_class << " table-danger" if order_line.action == 'S'
    html_class << " table-info" if order_line.action == 'N' && order_line.large_order_yn == 'Y'
    html_class
  end

  def binpick_repl_class(binpick_replenishment)
    html_class = "fatrow"
    html_class << " table-warning" if binpick_replenishment.row_type != BinpickReplenishment::PICK
    html_class
  end

  def binpick_qoh_class(binpick_replenishment)
    html_class = "text-right align-middle"
    html_class << " table-danger" if binpick_replenishment.net_required > binpick_replenishment.from_qoh
    html_class
  end

  def binpick_bin_select_action
    select_tag 'orderline_action_filter',
               options_for_select(@orderline_actions, session[:filter]['orderline_action_filter'] || 'N')
  end

  def binpick_batch_select_status
    select_tag 'batch_status_filter',
               options_for_select(@batch_statuses, session[:filter]['batch_status_filter'] || 'All')
  end

  def display_binpick_bin_item(bin_item)
    t('binpick_bin_item.display', { open: bin_item.open_qty.to_i.to_s,
                                    pick: bin_item.pick_qty.to_i.to_s,
                                    item: bin_item.item_display })
  end

  def binpick_bin_deassign(binpick_bin_summary)
    return unless binpick_bin_summary.assigned_yn == 'Y'
    link_to binpick_bin_deassign_path(binpick_bin_summary.id.to_i.to_s), method: :put, class: 'btn btn-sm btn-primary' do
      icon('user-slash') + t('binpick_bin.deassign')
    end
  end

  def binpick_bin_release(binpick_bin)
    return unless binpick_bin
    link_to binpick_bin_release_path(binpick_bin.id.to_i.to_s), method: :put,
            data: { confirm: t('binpick_bin.confirm_release') }, class: 'btn btn-sm btn-primary' do
      icon('user-slash') + t('binpick_bin.release')
    end
  end

  def binpick_bin_defer(binpick_bin)
    return unless binpick_bin
    link_to binpick_bin_defer_path(binpick_bin.id.to_i.to_s), method: :put,
            data: { confirm: t('binpick_bin.confirm_defer') }, class: 'btn btn-sm btn-primary' do
      icon('user-slash') + t('binpick_bin.defer')
    end
  end

  def binpick_bin_summary_select_action
    select_tag 'bin_summary_status_filter',
               options_for_select(@bin_summary_statuses, session[:filter]['bin_summary_status_filter'] || 'Assigned')
  end

  def summary_row_color(binpick_bin_summary)
    return "table-primary" if binpick_bin_summary.assigned_yn == 'Y'
    return "table-success" if binpick_bin_summary.status == 'Complete'
    return "table-danger" if binpick_bin_summary.status == 'Deferred'
    return "table-warning" if binpick_bin_summary.pick_type == 'ALL ORDERS'
    return "table-info" if binpick_bin_summary.pick_type == 'WAVE PICK'
    ""
  end

  def no_dup(prev_row, this_row, field)
    (prev_row && this_row && prev_row.item_no == this_row.item_no) ? nil : field
  end

  def delete_it(binpick_replenishment)
    return unless binpick_replenishment
    return unless binpick_replenishment.row_type == BinpickReplenishment::PUTAWAY
    link_to delete_it_binpick_replenishments_path(:params => { binpick_replenishment_id: binpick_replenishment.id }),
            method: :put,
            data: { confirm: t('binpick_replenishment.confirm_delete') },
            class: 'btn btn-sm btn-primary' do
      icon('trash')
    end
  end

  def binpick_stat_message(binpick_batch_summary)
    if binpick_batch_summary.stat_type == 'Replenishments Pending'
      link_to binpick_replenishments_path, class: 'btn btn-sm btn-danger' do
        icon('dolly') + t('menu.binpick_replenishments_link')
      end
    else
      binpick_batch_summary.stat_message
    end
  end

  def batch_summary_row_color(binpick_batch_summary)
    return "table-danger" if binpick_batch_summary.stat_type == 'Replenishments Pending'
    ""
  end

  def message_row_color(binpick_batch_message)
    return "text-center text-white bg-danger" if binpick_batch_message.severity == 'W'
    return "text-center text-white bg-info" if binpick_batch_message.severity == 'I'
    return "text-center"
  end

  def binpick_shipping_status_filter
    select_tag 'binpick_shipping_status_filter',
               options_for_select(@orders_shipping_statuses, session[:filter]['binpick_shipping_status_filter'])
  end

  def binpick_size_filter
    select_tag 'binpick_size_filter', options_for_select(@orders_sizes, session[:filter]['binpick_size_filter'])
  end

  def binpick_wave_filter
    select_tag 'binpick_wave_filter', options_for_select(@orders_waves, session[:filter]['binpick_wave_filter'])
  end

  def binpick_pick_type_filter
    select_tag 'binpick_pick_type_filter',
               options_for_select(BinpickBinSummary::PICK_TYPES, session[:filter]['binpick_pick_type_filter'])
  end

  def binpick_orders_color(binpick_order)
    html_class = " "
    html_class << " table-info" if binpick_order.large_order_yn == 'Y'
    html_class << " table-danger" if binpick_order.shipping_status == 'INVALID'
    html_class
  end

  def bin_item_popup(binpick_bin_summary)
    link_to binpick_bin_summary.area_bin, binpick_bin_items_path(:params => { binpick_bin_id: binpick_bin_summary.id }),
            data: { colorbox: true }
  end

  def binpick_order_popup(binpick_order)
    link_to binpick_order.order_display, binpick_order_lines_path(:params => { binpick_order_id: binpick_order.id }),
            data: { colorbox: true }
  end

  def binpick_order_delete(binpick_batch, binpick_order)
    return unless binpick_batch.status == 'O'
    link_to binpick_order_path(binpick_order), method: :delete,
            data: { confirm: t('binpick_order.confirm_delete') }, class: 'btn btn-sm btn-primary' do
      icon('trash')
    end

  end

  def binpick_order_line_color(order_line)
    html_class = " "
    html_class << "table-danger" if order_line.action == 'S'
    html_class << "table-info" if order_line.action == 'N' && order_line.large_order_yn == 'Y'
    html_class
  end

  def binpick_item_lines_link(binpick_bin_item)
    link_to formatted_qty(binpick_bin_item.line_count),
            line_count_binpick_order_lines_path(:params => { binpick_bin_item_id: binpick_bin_item.id }),
            data: { colorbox: true }
  end

  def binpick_item_openq_link(binpick_bin_item)
    return 0 if binpick_bin_item.open_qty == 0
    link_to formatted_qty(binpick_bin_item.open_qty),
            line_count_binpick_order_lines_path(:params => { binpick_bin_item_id: binpick_bin_item.id, open_qty: true }),
            data: { colorbox: true }
  end

  def binpick_item_shipq_link(binpick_bin_item)
    return 0 if binpick_bin_item.qty_shipped == 0
    link_to formatted_qty(binpick_bin_item.qty_shipped),
            line_count_binpick_order_lines_path(:params => { binpick_bin_item_id: binpick_bin_item.id, qty_shipped: true }),
            data: { colorbox: true }
  end

  def binpick_item_backq_link(binpick_bin_item)
    return 0 if binpick_bin_item.qty_backordered == 0
    link_to formatted_qty(binpick_bin_item.qty_backordered),
            line_count_binpick_order_lines_path(:params => { binpick_bin_item_id: binpick_bin_item.id, qty_backordered: true }),
            data: { colorbox: true }
  end

  def binpick_batch_client_filter
    select_tag 'binpick_batch_client_filter',
               options_for_select(@select_clients, session[:filter]['binpick_batch_client_filter'])
  end

  def binpick_batch_user_filter
    select_tag 'binpick_batch_user_filter',
               options_for_select(@select_users, session[:filter]['binpick_batch_user_filter'])
  end

  def binpick_emp_sum_drill_link(empno)
    link_to empno, binpick_emp_sum_path(empno), data: { colorbox: true }
  end

  def binpick_wave_picks_link(batch)
    return unless batch.has_wave_picks?
    link_to t('binpick_bin.wave_pick_link'), binpick_wave_picks_path(batch.id), class: 'btn btn-sm btn-primary'
  end


end
