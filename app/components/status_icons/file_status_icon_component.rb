# frozen_string_literal: true

module StatusIcons
  # Metadata status icon component
  class FileStatusIconComponent < StatusIconComponent
    def additional_classes
      'pod-metadata-status'
    end

    def settings_data
      Settings.file_status
    end
  end
end
