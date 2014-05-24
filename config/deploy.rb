require "bundler/capistrano"

server "112.124.48.51", :web, :app, :db, primary: true

set :application, "keke-games-leaderboards-api"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository,  "git@github.com:tomwey/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# 保留5个最新的版本
after "deploy", "deploy:cleanup"
# after "deploy:cleanup", "deploy:remote_rake"

namespace :deploy do
    
  task :setup_config, roles: :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml.example"), "#{shared_path}/config/database.yml"
    put File.read("config/listen.god.example"), "#{shared_path}/config/listen.god"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"
  
  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/listen.god #{release_path}/config/listen.god"
    # run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
  
  task :start_god do
    run "cd #{current_path}; god -c config/listen.god"
  end
  
end

