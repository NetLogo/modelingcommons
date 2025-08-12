# -*-ruby-*-

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

ruby '2.2.0'

source 'https://rubygems.org'
gem "rails", "~> 3.2.21"

gem 'geolocater'
gem 'geocoder'

gem 'json', '~> 1.8.5'

gem "country_select", '~> 1.2.0'
gem "newrelic_rpm"
gem 'BlueCloth', '~> 1.0.1'
gem 'GraphvizR', '~> 0.5.1'
gem 'acts_as_tree'
gem 'bson_ext'
gem 'builder'
gem 'capistrano', '~> 2.15.5'
gem 'diff-lcs'
gem 'hoptoad_notifier'
gem 'paperclip', '~> 3.4.1'
gem 'pg', '~> 0.15.1'
gem 'pry'
gem 'pry-nav'
gem 'pry-rails'
gem 'pry-remote'
gem 'rack'
gem 'rmagick', '~> 2.16.0', :require => 'RMagick'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'validate_email'
gem 'will_paginate', '~> 3.0.4'

gem 'zippy', '~> 0.2.1'
gem 'zip', '~> 2.0.2'
gem 'rubyzip', '~> 0.9.1'

gem 'twitter', '~> 4.8.0'
gem 'minitest'
gem 'test-unit'

group :test do
  gem "cucumber"
  gem "cucumber-rails", :require => false
  gem 'factory_girl_rails', "~> 4.0"
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov-text', :require => false
end

group :development do
  gem 'xray-rails'
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'letter_opener'
  gem 'awesome_print'
  gem 'database_cleaner', '~> 1.0.0RC1'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'watir-webdriver'
end

gem 'compass-rails', '~> 1.0.3'
gem 'sass-rails', '~> 3.2.6'

group :assets do
  gem 'coffee-rails'
  gem 'haml'
  gem 'jquery-rails'
  gem 'therubyracer'
  gem 'uglifier'
end
