set :application, "NetLogo Modeling Commons"

default_run_options[:pty] = true
set :repository,  "git@lerner.co.il:/home/git/nlcommons.git"
set :scm, "git"
set :scm_passphrase, "" #This is your custom users password
set :user, "deploy"
set :branch, 'master'

role :db, "lerner.co.il"
role :app, "lerner.co.il"
role :web, "lerner.co.il"

set :deploy_to, "/var/www/www.modelingcommons.org/www/"
set :deploy_via, :export

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end



