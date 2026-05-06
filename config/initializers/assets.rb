# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.scss, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( application.css
rails_bootstrap_forms.css
table.css
colorbox-rails.css
bootstrap.css
jquery-ui/core.css
jquery-ui/datepicker.css
jquery-ui/slider.css
jquery-ui/tabs.css
 )
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')


