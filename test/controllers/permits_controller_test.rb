# frozen_string_literal: true

require 'test_helper'

class PermitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
    @client = clients(:first)
    @user = users(:user)
  end

  teardown do
    Rails.cache.clear
  end

  test 'admin user should get index' do
    get admin_permits_url
    assert_response :success
  end

  test 'admin user should get new' do
    get new_admin_permit_url
    assert_response :success
  end

  test 'admin user should create permit' do
    assert_difference('Permit.count', +1) do
      post admin_permits_url, params: { permit: { report_name: 'New Report', client_id: @client.id, user_id: @user.id } }
    end
    assert_redirected_to admin_permits_url
  end

  test 'admin user should get edit' do
    @permit = permits(:one)
    get edit_admin_permit_url(@permit)
    assert_response :success
  end

  test 'admin user should update permit' do
    @permit = permits(:two)
    patch admin_permit_url(@permit), params: { permit: { report_name: 'Updated' } }
    assert_redirected_to admin_permits_url
    @permit.reload
    assert_equal 'Updated', @permit.report_name
  end

  test 'admin user should destroy permit' do
    @permit = permits(:three)
    assert_difference('Permit.count', -1) do
      delete admin_permit_url(@permit)
    end
    assert_redirected_to admin_permits_url
  end

  test 'ordinary user should NOT get index' do
    sign_in users(:user)
    get admin_permits_url
    assert_redirected_to root_url
  end

  test 'host user should NOT get index' do
    sign_in users(:host)
    get admin_permits_url
    assert_redirected_to root_url
  end


end
