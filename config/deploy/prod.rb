server 'pod.stanford.edu', user: 'pod', roles: %w(web db app background) # remove background here when we switch to the pod-redis-prod-a
server 'pod-worker-prod-a.stanford.edu', user: 'pod', roles: %w(background)
server 'pod-worker-prod-b.stanford.edu', user: 'pod', roles: %w(background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
set :sidekiq_roles, :background
