# Allow uploaded SVGs to be rendered inline https://github.com/rails/rails/issues/34665
ActiveStorage::Engine
  .config
  .active_storage
  .content_types_to_serve_as_binary
  .delete('image/svg+xml')
