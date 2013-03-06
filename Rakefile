# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/task'
require 'tasks/rails'

module Rails
  class VendorGemSourceIndex
    def version_for_dir(d)
      tokens = d.split('-')
      last = tokens.pop
      Gem::Version.new(last =~ /[^-a-z)]+$/ ? last : tokens.last)
    end
  end
end
