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

before "deploy:assets:precompile", "deploy:yarn_install"

namespace :deploy do
  desc 'Run rake yarn:install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end

  after :restart, :restart_sidekiq do
    on roles(:background) do
      sudo :systemctl, "restart", "sidekiq-*", raise_on_non_zero_exit: false
    end
  end
end

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
