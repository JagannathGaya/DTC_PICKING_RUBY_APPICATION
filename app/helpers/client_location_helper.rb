module ClientLocationHelper

  def client_locations_link(client)
    link_to admin_client_client_locations_path(client), class: 'btn btn-primary btn-sm' do
      icon('arrow-circle-right') + t('client.locations')
    end
  end

  def edit_client_location_link(client, client_location)
    link_to client_location.sls_location, edit_admin_client_client_location_path(client, client_location), data: {colorbox: true}
  end

  def new_client_location_link(client)
    link_to new_admin_client_client_location_path(client), class: 'btn btn-primary btn-sm', data: {colorbox: true} do
      icon('plus') + t('client_location.new')
    end
  end

  def delete_client_location_link(client, client_location)
    return unless client_location
    link_to admin_client_client_location_path(client, client_location), method: :delete,
            data: {confirm: t('client_location.confirm_delete')}, class: 'btn btn-primary btn-sm' do
      icon('trash') + t('client_location.delete')
    end
  end

end