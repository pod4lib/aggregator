# frozen_string_literal: true

# Job status icon component
class JobStatusIconComponent < MetadataStatusIconComponent
  def i_classes
    "#{icon_class} #{status} pod-job-tracker-status"
  end

  def settings_data
    Settings.job_status_group
  end

  def aria
    { label: status }
  end
end
