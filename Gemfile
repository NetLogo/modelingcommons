# -*-ruby-*-

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end


source 'https://rubygems.org'
gem "rails", "~> 3.2.13"

gem "compass", "0.11.7"
gem "country_select"
gem "newrelic_rpm" 
gem 'BlueCloth'
gem 'GraphvizR'
gem 'acts_as_tree'
gem 'bson_ext'
gem 'builder'
gem 'capistrano'
gem 'diff-lcs'
gem 'hoptoad_notifier'
gem 'paperclip'
gem 'pg'
gem 'rack'
gem 'rmagick'
gem 'validates_email'
gem 'will_paginate'
gem 'zippy'


group :test do
  gem "cucumber"
  gem "cucumber-rails"
  gem 'factory_girl'
  gem 'fuubar-legacy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'simplecov', :require => false
end

group :development, :test do
  gem 'awesome_print'
  gem 'database_cleaner'
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote'
  gem 'pry-rails'
  gem 'rb-fsevent'
  gem 'watir-webdriver'
end
