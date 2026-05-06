# frozen_string_literal: true

require 'test_helper'

class ClientLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
    @client = clients(:first)
  end

  teardown do
    Rails.cache.clear
  end

  test 'admin user should get index' do
    get admin_client_client_locations_url(@client)
    assert_response :success
  end
  # No Oracle Test DB available
  # test 'admin user should get new' do
  #   get new_admin_client_client_location_url(@client)
  #   assert_response :success
  # end

  test 'admin user should create client_location' do
    assert_difference('ClientLocation.count', +1) do
      post admin_client_client_locations_url(@client), params: { client_location: { name: 'New Location', client_id: @client.id, sls_location: 'NEW' } }
    end
    assert_redirected_to admin_client_client_locations_url(@client)
  end

  # No Oracle Test DB available
  # test 'admin user should get edit' do
  #   @client_location = client_locations(:one)
  #   get edit_admin_client_client_location_url(@client,@client_location)
  #   assert_response :success
  # end

  test 'admin user should update client_location' do
    @client_location = client_locations(:two)
    patch admin_client_client_location_url(@client,@client_location), params: { client_location: { name: 'Updated' } }
    assert_redirected_to admin_client_client_locations_url(@client)
    @client_location.reload
    assert_equal 'Updated', @client_location.name
  end

  test 'admin user should destroy client_location' do
    @client_location = client_locations(:three)
    assert_difference('ClientLocation.count', -1) do
      delete admin_client_client_location_url(@client,@client_location)
    end
    assert_redirected_to admin_client_client_locations_url(@client)
  end

  test 'ordinary user should NOT get index' do
    sign_in users(:user)
    get admin_client_client_locations_url(@client)
    assert_redirected_to root_url
  end

  test 'host user should NOT get index' do
    sign_in users(:host)
    get admin_client_client_locations_url(@client)
    assert_redirected_to root_url
  end


end
