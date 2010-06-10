set :application, "NetLogo Modeling Commons"

default_run_options[:pty] = true
set :repository,  "git@main.lerner.co.il:/home/git/nlcommons.git"
set :scm, "git"
set :scm_passphrase, "" #This is your custom users password
set :user, "deploy"
set :branch, 'master'

role :db, "main.lerner.co.il", :primary => true
role :app, "main.lerner.co.il"
role :web, "main.lerner.co.il"

set :deploy_to, "/var/www/www.modelingcommons.org/www/"
set :deploy_via, :export

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


namespace :rake do
 desc "Generate a sitemap on a remote server."
 task :generate_sitemap do
    run("cd #{deploy_to}/current; /usr/bin/rake sitemap:generate RAILS_ENV=production")
 end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
