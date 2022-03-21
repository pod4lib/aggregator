# frozen_string_literal: true

# Associate background jobs with records
class JobTracker < ApplicationRecord
  belongs_to :reports_on, polymorphic: true
  belongs_to :resource, polymorphic: true

  def resource_label
    return resource.filename if resource.is_a? ActiveStorage::Blob
    return resource.name if resource.is_a? Upload

    resource_id
  end

  def status
    @status ||= ActiveJob::Status.get(job_id)
  end

  def sidekiq_status
    return 'retry' if in_retry_set?
    return 'dead' if in_dead_set?

    'active'
  end

  def in_retry_set?
    @in_retry_set ||= sidekiq_set(Sidekiq::RetrySet).map(&:item).any? do |j|
      j['jid'] == provider_job_id
    end
  end

  def in_dead_set?
    @in_dead_set ||= sidekiq_set(Sidekiq::DeadSet).map(&:item).any? do |j|
      j['jid'] == provider_job_id
    end
  end

  def progress_label
    return number_with_delimiter(progress) unless total?

    "#{number_with_delimiter(progress)} of #{number_with_delimiter(total)}"
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

  private

  def number_with_delimiter(*args)
    ActiveSupport::NumberHelper.number_to_delimited(*args)
  end

  def sidekiq_set(set)
    set.new
  rescue Redis::CannotConnectError => e
    Rails.logger.info(e)
    Honeybadger.notify(e)
    []
  end
end
