# frozen_string_literal: true

module StatusIcons
  # Metadata status icon component
  class UploadStatusIconComponent < StatusIconComponent
    def additional_classes
      'pod-metadata-status'
    end

    def settings_data
      Settings.upload_status
    end
  end
end
