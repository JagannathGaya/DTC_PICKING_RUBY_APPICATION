module OrderLineHelper


  def start_pick_link
    link_to start_pick_order_lines_path, method: :put, class: 'btn btn-sm btn-primary' do
      icon('play') + t('order.start_pick')
    end
  end

  def view_order_lines_link
    link_to order_lines_path, method: :get, class: 'btn btn-sm btn-primary' do
      icon('play') + t('menu.lines_link')
    end
  end


end