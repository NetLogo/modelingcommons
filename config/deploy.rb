require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :application, "NetLogo Modeling Commons"

default_run_options[:pty] = true
set :repository,  "git@github.com:reuven/modelingcommons.git"
set :scm, "git"
set :scm_passphrase, "" #This is your custom users password
set :user, "deploy"
set :branch, 'master'

role :db, "modeling.tech.northwestern.edu", :primary => true
role :app, "modeling.tech.northwestern.edu"
role :web, "modeling.tech.northwestern.edu"

set :stages, %w(staging production)
set :default_stage, "staging"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

set :deploy_via, :export

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
