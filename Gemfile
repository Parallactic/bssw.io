# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.2.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'mysql2'
gem 'rails', '7.0.4'
gem 'sqlite3'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails' # , '6.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'execjs'
# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', github: 'rails/jbuilder', branch: 'master'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'bootstrap-sass'

group :development, :test do
  gem 'brakeman'
#  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'faker'
  #  gem 'metric_fu', github: 'eamonn-webster/metric_fu'
  gem 'rails-controller-testing'
  gem 'reek'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'rubycritic'
  gem 'simplecov'
end

gem 'github_api'
gem 'loofah'
gem 'nikkou'
gem 'nokogiri'

gem 'redcarpet'

gem 'capistrano', '~> 3.7'
gem 'capistrano-rails', '~> 1.2'

gem 'capistrano-bundler'
gem 'capistrano-rvm'

gem 'acts-as-taggable-on', '~> 4.0'
gem 'chronic'
gem 'friendly_id' # , '5.3.0'

gem 'headhunter'
gem 'pry'
gem 'ransack'

gem 'truncate_html'

gem 'mail_form'
gem 'simple_form'

gem 'capybara'
gem 'capybara-email'

gem 'lightbox-bootstrap-rails'
gem 'will_paginate'

gem 'exception_handler'
gem 'exception_notification'

gem 'cloudinary'

gem 'attempt'

gem 'ffi'

gem 'invisible_captcha'

gem 'octokit'

gem 'awesome_print'

gem 'stemmify'

gem 'lemmatizer'

gem 'geocoder'

gem 'mechanize'
gem 'rubyzip'

gem 'scout_apm'

gem 'activerecord-import'
gem 'store_method', github: 'fomichov/store_method'

gem 'sucker_punch'

gem 'rack-utf8_sanitizer'

# gem "handle_invalid_percent_encoding_requests"
gem 'rouge-rails'
gem 'warning'

gem 'bcrypt_pbkdf'
gem 'ed25519'

gem 'algoliasearch-rails'

gem 'faraday' # , '1.10.3'
gem 'human_time'

