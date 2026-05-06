module PickHelper

  def display_order(pick)
    pick.order_no.to_s + '-' + pick.order_suffix.to_s if pick.order_no
  end

  def finish_pick_link
    link_to finish_pick_picks_path, method: :put, class: 'btn btn-sm btn-primary' do
      icon('play') + t('pick.finish_pick')
    end
  end

end