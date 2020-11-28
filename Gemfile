source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# util
gem 'config'
gem 'dotenv-rails'
gem 'rails-i18n'
gem 'enum_help'
gem 'rmagick'
gem 'carrierwave'
gem 'carrierwave-base64'
gem 'carrierwave-magic'
gem 'acts-as-taggable-on'
gem 'piet'
gem 'fog-aws'
gem 'bullet'

# API
gem 'grape'
gem 'hashie-forbidden_attributes'
gem 'grape-jbuilder'
gem 'grape_on_rails_routes'
gem 'swagger-ui_rails'
gem 'grape-swagger'
gem 'grape-swagger-rails'

gem 'devise'
gem 'devise_token_auth'
gem 'grape_devise_token_auth'
gem 'devise-i18n'

# DB
gem 'ridgepole'
gem 'seed-fu'
gem "discard" # soft delete
gem 'default_value_for'
gem 'counter_culture'

# Paging
gem 'kaminari'

# Search
gem 'ransack'

# Google Play Billing
gem 'google-api-client', '0.17.3', require: ['google/apis/androidpublisher_v2']
