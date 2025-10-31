require 'active_storage_attachment_metadata_status'
require 'active_storage_blob_content_types'

# Allow uploaded SVGs to be rendered inline https://github.com/rails/rails/issues/34665
ActiveStorage::Engine
  .config
  .active_storage
  .content_types_to_serve_as_binary
  .delete('image/svg+xml')

Rails.application.reloader.to_prepare do
  Rails.application.config.active_storage.analyzers.append DeletesAnalyzer
  Rails.application.config.active_storage.analyzers.append MarcAnalyzer
end


Rails.configuration.to_prepare do
  ActiveStorage::Attachment.send :include, ::ActiveStorageAttachmentMetadataStatus
  ActiveStorage::Blob.send :include, ::ActiveStorageBlobContentTypes
end
