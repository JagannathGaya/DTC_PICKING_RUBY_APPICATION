require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'rails/all'

require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tbcorp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 6.0

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.active_record.raise_in_transactional_callbacks = true obsolete in 5.1
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]
    # config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.active_job.queue_adapter = :delayed_job
    config.action_dispatch.default_headers.merge!('X-UA-Compatible' => 'IE=edge')
    config.intranet_user_email = '@tb.local'
    config.permit_targets = [
        {controller: 'OrdersController', method: 'index', name: 'Select Orders for Pick by Order'},
        {controller: 'OrderLinesController', method: 'index', name: 'View Order Lines for Pick by Order'},
        {controller: 'PicksController', method: 'index', name: 'Pick Orders for Pick by Order'},
        {controller: 'BinpickBatchesController', method: 'index', name: 'Manage Batches for Pick by Bin'},
        {controller: 'BinpickBinsController', method: 'index', name: 'Pick by Bin'},
        {controller: 'ReceiptBatchesController', method: 'index', name: 'Manage Receipt Batches'},
        {controller: 'WhouseItemsController', method: 'index', name: 'Use Item Finders'},
    ]
  end
end
# Dir.glob("#{Rails.root.join('app','services')}/*.rb").each {|source_file| require source_file}

# Rails.autoloaders.log!
