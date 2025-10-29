# frozen_string_literal: true

# Stream job status component
class StreamJobRowComponent < ViewComponent::Base
  def initialize(job_tracker, status)
    @job_tracker = job_tracker
    @status = status
    super()
  end
  attr_reader :job_tracker, :status

  delegate :datetime_display_format, :local_time, to: :helpers

  delegate :resource, to: :job_tracker

  def resource_label
    return resource.filename if resource.is_a? ActiveStorage::Blob

    resource.name || resource.slug
  end

  def progress_label
    return unless job_tracker.progress
    return number_with_delimiter(job_tracker.progress) unless job_tracker.total&.positive?

    "#{number_with_delimiter(job_tracker.progress)} of #{number_with_delimiter(job_tracker.total)}"
  end
end
