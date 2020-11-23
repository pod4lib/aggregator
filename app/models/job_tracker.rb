# frozen_string_literal: true

# Associate background jobs with records
class JobTracker < ApplicationRecord
  belongs_to :reports_on, polymorphic: true
  belongs_to :resource, polymorphic: true

  def label
    "[#{job_class.titleize}] #{resource_label}"
  end

  def resource_label
    return resource.filename if resource.is_a? ActiveStorage::Blob
    return resource.name if resource.is_a? Upload

    resource_id
  end

  def status
    @status ||= ActiveJob::Status.get(job_id)
  end

  def progress_label
    return number_with_delimiter(progress) unless total?

    "#{number_with_delimiter(progress)} / #{number_with_delimiter(total)}"
  end

  def progress
    return 0 unless status[:progress]

    status[:progress]
  end

  def total
    return progress unless total?

    status[:total]
  end

  def total?
    return false unless status[:total]

    status[:total]&.positive?
  end

  def percent
    return nil unless total?

    (100.0 * progress) / total
  end

  private

  def number_with_delimiter(*args)
    ActiveSupport::NumberHelper.number_to_delimited(*args)
  end
end
