server 'pod-prod.stanford.edu', user: 'pod', roles: %w(web db app)
server 'pod-worker-prod-a.stanford.edu', user: 'pod', roles: %w(background)
server 'pod-worker-prod-b.stanford.edu', user: 'pod', roles: %w(background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
