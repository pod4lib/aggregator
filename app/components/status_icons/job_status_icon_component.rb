# frozen_string_literal: true

module StatusIcons
  # Job status icon component
  class JobStatusIconComponent < StatusIconComponent
    def settings_data
      Settings.job_status_group
    end

    def additional_classes
      'pod-job-tracker-status'
    end

    def aria
      { label: status }
    end
  end
end
