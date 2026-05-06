# frozen_string_literal: true

require 'test_helper'
class LogRequest

end

class LogRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
  end

  teardown do
    Rails.cache.clear
  end

  test 'should get tail index' do
    get admin_log_requests_url
    assert_response :success
  end

  test 'should get routing failure index' do
    get routing_failures_admin_log_requests_url
    assert_response :success
  end

  test 'host user should not get index' do
    sign_in users(:host)
    get admin_log_requests_url
    assert_redirected_to root_path
  end

  test 'ordinary user should not get index' do
    sign_in users(:user)
    get admin_log_requests_url
    assert_redirected_to root_path
  end

end
