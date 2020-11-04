Honeybadger.configure do |config|
  config.exceptions.ignore += [Mime::Type::InvalidMimeType]
end
