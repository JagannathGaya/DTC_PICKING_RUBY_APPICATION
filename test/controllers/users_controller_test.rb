# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    self.default_url_options = { locale: I18n.default_locale }
    @client = clients(:first)
    @user = users(:user)
    sign_in users(:admin)
  end

  teardown do
    Rails.cache.clear
  end

  test 'should get index' do
    get admin_users_url
    assert_response :success
  end

  test 'manager should not get index' do
    sign_in users(:host)
    get admin_users_url
    assert_redirected_to root_path
  end

  test 'ordinary user should not get index' do
    sign_in users(:user)
    get admin_users_url
    assert_redirected_to root_path
  end

  test 'should get new' do
    get new_admin_user_url
    assert_response :success
  end

  test 'should create user' do
    assert_difference('User.count') do
      post admin_users_url, params: { user: { name: 'New User', email: 'newuser@example.com', user_type: 'user',
                                              password: "<%= User.new.send(:password_digest, 'password') %>",
                                              client_id: @client.id } }
    end
    assert_redirected_to admin_users_url
  end

  test 'should get edit' do
    get edit_admin_user_url @user
    assert_response :success
  end

  test 'should update user' do
    patch admin_user_url(@user), params: { user: { name: 'Updated',
                                                   password: "<%= User.new.send(:password_digest, 'password') %>" } }
    assert_redirected_to admin_users_url
    @user.reload
    assert_equal 'Updated', @user.name
  end

  test 'should destroy user' do
    @deleter = users(:deleter)
    assert_difference('User.count', -1) do
      delete admin_user_url(@deleter)
    end
    assert_redirected_to admin_users_url
  end

  test 'should impersonate user' do
    put impersonate_admin_user_url @user
    assert_redirected_to root_url
    follow_redirect!
    assert_match @user.name, @response.body
  end

  test 'should unlock user' do
    put unlock_admin_user_url @user
    assert_redirected_to admin_users_url
  end
end
