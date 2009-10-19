# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'metric_fu'

MetricFu::Configuration.run do |config|
  config.rcov[:rcov_opts] << "-Itest"
  config.rcov[:run_cucumber] = true
end

desc "Build a code coverage report"
task :coverage do
  files = test_files.join(" ")
  sh "rcov -o coverage #{files} --exclude ^/Library/Ruby/,^init.rb --include lib/ --include-file ^lib/.*\\.rb"
end
