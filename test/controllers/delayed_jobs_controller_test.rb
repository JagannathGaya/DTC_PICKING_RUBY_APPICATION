# frozen_string_literal: true

require 'test_helper'

class DelayedJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    sign_in users(:admin)
  end

  teardown do
    Rails.cache.clear
  end

  test 'should get index' do
    get admin_delayed_jobs_url
    assert_response :success
  end

  test 'host should not get index' do
    sign_in users(:host)
    get admin_delayed_jobs_url
    assert_redirected_to root_path
  end

  test 'ordinary user should not get index' do
    sign_in users(:user)
    get admin_delayed_jobs_url
    assert_redirected_to root_path
  end

end
