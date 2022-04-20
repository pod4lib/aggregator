server 'pod-stage.stanford.edu', user: 'pod', roles: %w(web db app background)
server 'pod-worker-stage-a.stanford.edu', user: 'pod', roles: %w(background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
set :sidekiq_roles, :background
