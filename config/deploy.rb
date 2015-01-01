# config valid only for Capistrano 3.1
lock "3.3.5"

set :application, "myblog"
set :repo_url, "git@github.com:johnny-miyake/myblog.git"
set :assets_roles, [:app]
set :deploy_ref, ENV["DEPLOY_TAG"]

if fetch(:deploy_ref)
  set :branch, fetch(:deploy_ref)
else
  raise "Please set $DEPLOY_TAG"
end

set :deploy_to, "/usr/local/rails_apps/#{fetch :application}"
set :pid_file, "#{shared_path}/tmp/pids/unicorn.pid"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, []

# Default value for linked_dirs is []
# NOTE: public/uploads IS USED ONLY FOR THE STAGING ENVIRONMENT
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

# Default value for default_env is {}
set :default_env, {
  rails_env: ENV["RAILS_ENV"],
  deploy_tag: ENV["DEPLOY_TAG"],
  aws_region: ENV["AWS_REGION"],
  aws_elb_name: ENV["AWS_ELB_NAME"],
  aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  devise_secret_key: ENV["DEVISE_SECRET_KEY"],
  database_hostname: ENV["DATABASE_HOSTNAME"],
  database_username: ENV["DATABASE_USERNAME"],
  database_password: ENV["DATABASE_PASSWORD"],
  database_name: ENV["DATABASE_NAME"],
  redis_hostname: ENV["REDIS_HOSTNAME"]
}

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc "create database"
  task :create_database do
    on roles(:db) do |host|
      within "#{release_path}" do
        with rails_env: ENV["RAILS_ENV"] do
          execute :rake, "db:create"
        end
      end
    end
  end
  before :migrate, :create_database

  desc "seed database"
  task :seed do
    on roles(:db) do |host|
      within "#{release_path}" do
        with rails_env: ENV["RAILS_ENV"] do
          execute :rake, "db:seed"
        end
      end
    end
  end
  after :migrate, :seed

  desc "Restart application"
  task :restart do
    on roles(:app) do
      execute "if test -f #{fetch :pid_file}; then kill -USR2 `cat #{fetch :pid_file}`; fi"
    end
  end
  after :publishing, :restart

  desc "update revision tag"
  task :update_revision_tag do
    on roles(:tag) do
      within "#{release_path}" do
        execute :rake, "tag:update_revision"
      end
    end
  end
  after :restart, :update_revision_tag
end
