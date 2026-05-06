module PermitHelper

  def edit_permit_link(permit)
    link_to permit.report_name, edit_admin_permit_path(permit), data: {colorbox: true, colorbox_width: 800, colorbox_height: 320}
  end

  def new_permit_link
    link_to new_admin_permit_path, class: 'btn btn-sm btn-primary', data: {colorbox: true, colorbox_width: 800, colorbox_height: 320} do
      icon('plus') + t('permit.new')
    end
  end

  def delete_permit_link(permit)
    return unless permit
    link_to admin_permit_path(permit), method: :delete, data: {confirm: t('permit.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') + t('permit.delete')
    end
  end

  def list_permits_link
    link_to admin_permits_path, class: 'btn btn-sm btn-primary' do
      icon('list') + t('permit.list_all')
    end
  end

  def permit_display_client(permit)
    return unless permit.client
    permit.client.cust_no+':'+permit.client.cust_name
  end

  def permit_display_user(permit)
    return unless permit.user
    permit.user.email+' ('+permit.user.name+')'
  end

  def permit_report_filter
    select_tag 'permit_report_filter', options_for_select(@reports , session[:filter]['permit_report_filter'])
  end

  def permit_client_filter
    select_tag 'permit_client_filter', options_for_select(@clients , session[:filter]['permit_client_filter'])
  end

  def permit_user_filter
    select_tag 'permit_user_filter', options_for_select(@users , session[:filter]['permit_user_filter'])
  end


end