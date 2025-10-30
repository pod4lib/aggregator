# frozen_string_literal: true

module StatusIcons
  # Metadata status icon component
  class MetadataStatusIconComponent < StatusIconComponent
    def additional_classes
      'pod-metadata-status'
    end

    def settings_data
      Settings.metadata_status
    end
  end
end
