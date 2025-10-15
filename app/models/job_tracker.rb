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

    'active' if in_queue? || in_workers?
  end

  def in_queue?
    @in_queue ||= in_sidekiq_set?(Sidekiq::Queue)
  end

  def in_workers?
    Sidekiq::Workers.new.each do |_process_id, _thread_id, work|
      return true if JSON.parse(work.payload)['jid'] == provider_job_id
    end
  rescue Errno::ECONNREFUSED
    false
  end

  def error_processing?
    in_retry_set? || in_dead_set?
  end

  def in_retry_set?
    @in_retry_set ||= in_sidekiq_set?(Sidekiq::RetrySet)
  end

  def in_dead_set?
    @in_dead_set ||= in_sidekiq_set?(Sidekiq::DeadSet)
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

  def number_with_delimiter(*)
    ActiveSupport::NumberHelper.number_to_delimited(*)
  end

  def in_sidekiq_set?(set)
    set_instance = set.new
    # NOTE: Guard against sequential scan of a set that is too large.
    return false if set_instance.size > 1000

    # NOTE: This does not scale and we might need to find an alternate approach:
    #       https://github.com/mperham/sidekiq/blob/main/lib/sidekiq/api.rb#L279-L286
    set_instance.find_job(provider_job_id).present?
  rescue RedisClient::CannotConnectError => e
    Rails.logger.info(e)
    Honeybadger.notify(e)
    false
  end
end
