require 'active_storage_attachment_metadata_status'
require 'active_storage_blob_content_types'

# Allow uploaded SVGs to be rendered inline https://github.com/rails/rails/issues/34665
ActiveStorage::Engine
  .config
  .active_storage
  .content_types_to_serve_as_binary
  .delete('image/svg+xml')

Rails.application.config.active_storage.analyzers.append DeletesAnalyzer
Rails.application.config.active_storage.analyzers.append MarcAnalyzer

# Use default queue for analysis and purge for Sidekiq simplification
Rails.application.config.active_storage.queues[:analysis] = :default
Rails.application.config.active_storage.queues[:purge] = :default


Rails.configuration.to_prepare do
  ActiveStorage::Attachment.send :include, ::ActiveStorageAttachmentMetadataStatus
  ActiveStorage::Blob.send :include, ::ActiveStorageBlobContentTypes
end
