Sidekiq.configure_server do |config|
  config.logger.level = Object.const_get(Settings.sidekiq.logger_level)
end
