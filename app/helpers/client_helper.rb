module ClientHelper

  def edit_client_link(client)
    link_to client.cust_no, edit_admin_client_path(client), data: {colorbox: true, colorbox_width: 850}
  end

  def new_client_link
    link_to new_admin_client_path, class: 'btn btn-sm btn-primary', data: {colorbox: true, colorbox_width: 850} do
      icon('plus') + t('client.new')
    end
  end

  def delete_client_link(client)
    return unless client
    link_to admin_client_path(client), method: :delete, data: {confirm: t('client.confirm_delete')}, class: 'btn btn-sm btn-primary' do
      icon('trash') + t('client.delete')
    end
  end

  def list_clients_link
    link_to admin_clients_path, class: 'btn btn-sm btn-primary' do
      icon('list') + t('client.list_all')
    end
  end

  def binpick_reset_link(client)
    link_to reset_batches_admin_client_path(client.id), method: :put,  data: { confirm: t('client.confirm_reset')}, class: 'btn btn-sm btn-primary' do
      icon('bomb') + t('client.reset_binpick_batches')
    end
  end



end