set :application, 'aggregator'
set :repo_url, 'https://github.com/ivplus/aggregator.git'


if ENV['DEPLOY']
  # Default branch is :master so we need to update to main
  set :branch, 'main'
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/opt/app/pod/aggregator"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/honeybadger.yml)

# Default value for linked_dirs is []
set :linked_dirs, %w(storage log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads config/settings)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, "#{fetch(:stage)}"

# Manage SolidQueue via systemd (from dlss-capistrano gem)
set :solid_queue_systemd_role, :app
set :solid_queue_systemd_use_hooks, true

before 'deploy:restart', 'shared_configs:update'
