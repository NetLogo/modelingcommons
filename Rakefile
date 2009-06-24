# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require 'metric_fu'

MetricFu::Configuration.run do |config|

  config.rcov     = {
    :test_files => ['test/*/*_test.rb'],
    :rcov_opts => ["-Itest --rails"]}
end
