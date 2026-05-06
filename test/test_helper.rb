# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers
    include Warden::Test::Helpers

    def log_in(user)
      if integration_test?
        # use Warden
        login_as(user, scope: :user)
      else # controller test, model test
        # use Devise
        sign_in(user)
      end
    end

    # add more stuff above me
    # ======================
  end
end
