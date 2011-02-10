# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
config.gem 'capybara',         :lib => false, :version => '>=0.3.5' 
config.gem 'cucumber'
config.gem 'cucumber-rails',   :lib => false, :version => '>=0.3.2' 
config.gem 'database_cleaner', :lib => false, :version => '>=0.5.0' 
config.gem 'ruby-debug'
config.gem 'rspec', :lib => false, :version => "1.3.1"
