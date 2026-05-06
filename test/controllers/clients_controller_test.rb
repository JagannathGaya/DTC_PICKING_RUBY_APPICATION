# frozen_string_literal: true

require 'test_helper'

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
  end

  teardown do
    Rails.cache.clear
  end

  test 'admin user should get index' do
    get admin_clients_url
    assert_response :success
  end

  test 'admin user should get new' do
    get new_admin_client_url
    assert_response :success
  end

  test 'admin user should create client' do
    assert_difference('Client.count', +1) do
      post admin_clients_url, params: { client: { cust_no: 'NEWCL', cust_name: 'New Client', email: 'newclient@example.com' } }
    end
    assert_redirected_to admin_clients_url
  end

  test 'admin user should get edit' do
    @client = clients(:first)
    get edit_admin_client_url(@client)
    assert_response :success
  end

  test 'admin user should update client' do
    @client = clients(:second)
    patch admin_client_url(@client), params: { client: { cust_name: 'Updated' } }
    assert_redirected_to admin_clients_url
    @client.reload
    assert_equal 'Updated', @client.cust_name
  end

  test 'admin user should destroy client' do
    @client = clients(:third)
    assert_difference('Client.count', -1) do
      delete admin_client_url(@client)
    end
    assert_redirected_to admin_clients_url
  end

  test 'ordinary user should NOT get index' do
    sign_in users(:user)
    get admin_clients_url
    assert_redirected_to root_url
  end

  test 'host user should NOT get index' do
    sign_in users(:host)
    get admin_clients_url
    assert_redirected_to root_url
  end


end
