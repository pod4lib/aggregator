# frozen_string_literal: true

# Associate background jobs with records
class JobTracker < ApplicationRecord
  belongs_to :reports_on, polymorphic: true
  belongs_to :resource, polymorphic: true
  store :data, accessors: %i[progress total error_message duration]

  belongs_to :solid_queue_job, class_name: 'SolidQueue::Job', primary_key: 'active_job_id', foreign_key: 'job_id', optional: true # rubocop:disable Rails/InverseOf

  def increment(value = 1)
    update(progress: (progress || 0) + value)
  end

  def self.clean_up_old_records(days_older_than: 7)
    where(created_at: ...days_older_than.days.ago).delete_all
  end
end
