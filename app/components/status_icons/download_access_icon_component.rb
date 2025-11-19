# frozen_string_literal: true

module StatusIcons
  # Download access status icon component
  class DownloadAccessIconComponent < StatusIconComponent
    def settings_data
      Settings.download_access_status
    end
  end
end
