# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'rack', :version => '1.1.2'
  config.gem 'hoptoad_notifier'
  config.gem 'mongo_mapper', :version => '0.8.6'
  config.gem 'paperclip', :source => 'http://rubygems.org'
  config.gem 'plucky', :version => '0.3.8'
  config.gem 'validates_email'
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  config.gem 'GraphvizR', :lib => 'graphviz_r'
  config.gem 'BlueCloth', :lib => 'bluecloth'
  config.gem "compass", :version => " 0.11.7"
  config.gem "newrelic_rpm" 

  # config.gem 'zip'
  # config.gem 'difflcs'
  # config.gem 'hpricot'

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => '_nlcommons_session',
    :secret      => 'efb755e46296661a3606b089381576ded95b9c8ae7697770963a5782b85fa009d0f98f8a2856d8b334d1224790e7cda374c7cc4c6f7058bade4b00f667175ae3',
    :expire_after => 2592000
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

require "will_paginate"
require 'validates_email'

if RUBY_VERSION == "1.9.2"
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# # Handle the creation of new processes by Phusion Passenger
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     STDERR.puts "MongoMapper.connection.class: '#{MongoMapper.connection.class}'"
#     STDERR.puts "MongoMapper.connection: '#{MongoMapper.connection}'"
#     STDERR.puts "MongoMapper.connection.methods: '#{MongoMapper.connection.methods}'"

#     MongoMapper.connection.connect_to_master if forked
#   end
# end
