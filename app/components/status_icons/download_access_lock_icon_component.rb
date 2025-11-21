# frozen_string_literal: true

module StatusIcons
  # Download access status icon component
  class DownloadAccessLockIconComponent < StatusIconComponent
    def settings_data
      Settings.download_access_lock_status
    end
  end
end
