Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] } if ENV['SIDEKIQ_REDIS_URL'].present?
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] } if ENV['SIDEKIQ_REDIS_URL'].present?
end
