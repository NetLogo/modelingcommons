# -*-ruby-*-

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end


source 'https://rubygems.org'
gem "rails", "~> 3.2.13"

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
gem 'rmagick', :require => 'RMagick'
gem 'validates_email'
gem 'will_paginate'
gem 'zippy'

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
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'awesome_print'
  gem 'database_cleaner', '~> 1.0.0RC1'
  gem 'guard'
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'rb-fsevent'
  gem 'watir-webdriver'
end

gem 'compass-rails'
gem 'sass-rails'

group :assets do 
  gem 'coffee-rails'
  gem 'haml'
  gem 'jquery-rails'  
  gem 'therubyracer'
  gem 'uglifier'
end
