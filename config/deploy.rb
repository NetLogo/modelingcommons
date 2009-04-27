set :application, "nlcommons"
set :repository,  "svn+ssh://monk.ccl.northwestern.edu/srv/svnrepos/ccl/nlcommons/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/www.modelingcommons.org/www/trunk"
set :deploy_via, :export

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :scm_username, 'reuven'
set :scm_password, proc{ Capistrano::CLI.password_prompt('Enter password:')}
set :use_sudo, false

role :app, "main.lerner.co.il"
role :web, "main.lerner.co.il"
role :db, "main.lerner.co.il", :primary => true

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
