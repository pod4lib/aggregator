server 'pod.stanford.edu', user: 'pod', roles: %w(web db app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
set :sidekiq_roles, :background
