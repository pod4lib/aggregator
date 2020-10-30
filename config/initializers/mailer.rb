if Settings&.action_mailer&.default_url_options
  Aggregator::Application.config.action_mailer.default_url_options = Settings.action_mailer.default_url_options.try(:to_h) || {}
end
