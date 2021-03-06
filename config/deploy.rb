require "bundler/capistrano"
#require "whenever/capistrano"

#def _cset(name, *args, &block)
#  unless exists?(name)
#    set(name, *args, &block)
#  end
#end

set :whenever_command, "bundle exec whenever"
set :application, "football_serv"
set :repository,  "git@github.com:jinooaction/football_serv.git"
set :branch, "master"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "14.63.163.75"                          # Your HTTP server, Apache/etc
role :app, "14.63.163.75"                          # This may be the same as your `Web` server
role :db,  "14.63.163.75", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "deployer"
set :password, "skdmlgksksla2015"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless 'git rev-parse HEAD' == 'git rev-parse origin/master'
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run 'git push' to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
  after "deploy:update_code", "deploy:migrate"
end
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
#
#
