# frozen_string_literal: true

require 'test_helper'

class PageRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
  end

  teardown do
    Rails.cache.clear
  end

  test 'should get index' do
    get admin_page_requests_url
    assert_response :success
  end

  test 'host should not get index' do
    sign_in users(:host)
    get admin_page_requests_url
    assert_redirected_to root_path
  end

  test 'ordinary user should not get index' do
    sign_in users(:user)
    get admin_page_requests_url
    assert_redirected_to root_path
  end

  test 'should get method_hits' do
    get method_hits_admin_page_requests_url
    assert_response :success
  end

  test 'should get db_runtimes' do
    get db_runtimes_admin_page_requests_url
    assert_response :success
  end
end
