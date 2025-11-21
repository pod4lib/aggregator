# frozen_string_literal: true

# :nodoc:
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def self.with_job_tracking # rubocop:disable Metrics/AbcSize
    before_perform :find_or_initialize_job_tracker
    after_enqueue :find_or_initialize_job_tracker
    around_perform do |job, block|
      job.job_tracker&.update(status: 'in progress') if job.job_tracker.status == 'enqueued'

      t = Time.current

      block.call

      job.job_tracker&.update(status: 'complete', duration: Time.current - t) if job.job_tracker.status == 'in progress'
    end

    after_discard do |job, exception|
      job.job_tracker&.update(status: 'error', error_message: exception.message)
    end
  end

  attr_reader :job_tracker

  private

  def find_or_initialize_job_tracker
    # NOTE: Using create_or_find_by! (which is atomic) to avoid creating duplicate JobTracker records
    # for the same job_id.
    @job_tracker = JobTracker.create_or_find_by!(job_id: job_id) do |tracker|
      tracker.status = 'enqueued'
      tracker.job_class = self.class.name
      tracker.resource = arguments.first
      tracker.reports_on = reports_on || tracker.resource.try(:organization)
    end
  end

  def reports_on
    resource = arguments.first

    case resource
    when Stream, Organization
      resource
    when Upload
      resource.stream
    end
  end
end
