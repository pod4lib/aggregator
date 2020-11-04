# Allow uploaded SVGs to be rendered inline https://github.com/rails/rails/issues/34665
ActiveStorage::Engine
  .config
  .active_storage
  .content_types_to_serve_as_binary
  .delete('image/svg+xml')

Rails.application.config.active_storage.analyzers.append BinaryMarcAnalyzer
Rails.application.config.active_storage.analyzers.append XmlMarcAnalyzer

# Use default queue for analysis and purge for Sidekiq simplification
Rails.application.config.active_storage.queues[:analysis] = :default
Rails.application.config.active_storage.queues[:purge] = :default
