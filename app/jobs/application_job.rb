# frozen_string_literal: true

# :nodoc:
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def self.with_job_tracking
    after_enqueue :find_or_initialize_job_tracker
  end

  private

  def find_or_initialize_job_tracker
    job = SolidQueue::Job.find_by(active_job_id: job_id)
    gid = job&.arguments&.[]('arguments')&.first&.[]('_aj_globalid')
    return unless gid

    resource = GlobalID::Locator.locate(gid)
    job.update!(organization_id: resource.organization.id)
  end
end
