# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

if ENV['RAILS_ENV'] != 'production'
#   require 'vendor/gems/jscruggs-metric_fu-1.5.1/lib/metric_fu'
end

module Rails
  class VendorGemSourceIndex
    def version_for_dir(d)
      tokens = d.split('-')
      last = tokens.pop
      Gem::Version.new(last =~ /[^-a-z)]+$/ ? last : tokens.last)
    end
  end
end
