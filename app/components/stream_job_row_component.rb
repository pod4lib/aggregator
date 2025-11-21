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

  def resource_label # rubocop:disable Metrics/AbcSize
    return resource.filename if resource.is_a? ActiveStorage::Blob
    return resource.files.first.filename if resource.is_a?(Upload) && resource.files.one?

    resource.name || resource.slug
  end

  def progress_label
    return unless job_tracker.progress
    return number_with_delimiter(job_tracker.progress) unless job_tracker.total&.positive?

    "#{number_with_delimiter(job_tracker.progress)} of #{number_with_delimiter(job_tracker.total)}"
  end

  def duration_label
    if job_tracker.duration
      distance_of_time_in_words(job_tracker.duration)
    elsif job_tracker.status == 'in progress'
      distance_of_time_in_words_to_now(job_tracker.created_at)
    end
  end
end
