module ApplicationHelper
  include CommonUtils

  def link_permitted?(target, user, method = 'index')
    PermitService.new(target, user, method, @current_client).allowed?
  end

  def user_user?
    current_user && current_user.user? ? true : false
  end

  def host_user?
    current_user && current_user.host? ? true : false
  end

  def admin_user?
    current_user && current_user.admin? ? true : false
  end

  def home_link
    link_to root_path, class: 'btn btn-sm btn-primary' do
      icon('home') + t(:home)
    end
  end

  def cancel_link
    link_to :back, class: 'btn btn-sm btn-primary' do
      icon('times') + t(:cancel)
    end
  end

  def back_link
    link_to :back, class: 'btn btn-sm btn-primary' do
      icon('arrow-circle-left') + t(:back)
    end
  end

  def export_link(controller, format, filters = nil)
    if filters
      link_to icon('arrow-circle-right') + t(format), {controller: '/' + controller, format: format, action: :index, params: filters}, class: 'btn btn-sm btn-primary'
    else
      link_to icon('arrow-circle-right') + t(format), {controller: '/' + controller, format: format, action: :index}, class: 'btn btn-sm btn-primary'
    end
  end

  def clear_filters_link(redirect_to_path)
    link_to icon('minus-circle') + t('clear_filters'), {controller: '/filter', action: :clear, params: {redirect_to: redirect_to_path}}, class: 'btn btn-sm btn-primary'
  end

  def drill_to_item_link(item_no)
    return unless item_no
    link_to item_no, tbdash_items_path(:params => {item_no_filter: item_no})
  end

  def sorter(redirect_to_path, column)
    link_to icon('sort') , {controller: '/filter', action: :sorter, method: :delete,
                            params: {redirect_to: redirect_to_path, column: column}}, class: 'btn btn-xs btn-primary'
  end

  def clients_for_selector
    locs = ClientLocation.using('pg').
        includes(:client).
        map { |s| ["#{s.client.cust_no}:#{s.client.cust_name} (#{s.sls_location})", 'L'+s.id.to_s] }
    cls = Client.using('pg').
        where('not exists (select 1 from client_locations where client_locations.client_id = clients.id)').
        map { |s| ["#{s.cust_no}:#{s.cust_name}", 'C'+s.id.to_s] }
    (locs+cls).sort
  end

  def selected_for_client_selector
    return 'L'+ @current_client_location.id.to_s if @current_client_location
    return 'C'+ @current_client.id.to_s if @current_client
    nil
  end

  private

  def icon(icon_name)
    "<span
class='fas fa-#{icon_name}'
aria-hidden='true'
style='display: inline-block; margin-bottom: -3px; padding-right: 4px;'></span>".to_s.html_safe
  end

  def qty_filter(column)
    select_tag column, options_for_select([[t(:all)], ['>0'], ['=0'], ['!=0'], ['<0']], session[:filter][column])
  end

end
