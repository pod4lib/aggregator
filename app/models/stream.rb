# frozen_string_literal: true

# :nodoc:
class Stream < ApplicationRecord
  has_paper_trail
  extend FriendlyId

  friendly_id :name, use: %i[finders slugged scoped], scope: :organization
  belongs_to :organization
  has_many :uploads, dependent: :destroy_async
  has_many :default_stream_histories, dependent: :delete_all, deprecated: true
  has_many :marc_records, through: :uploads, inverse_of: :stream
  has_many :files, source: :files_attachments, through: :uploads
  has_one :statistic, dependent: :delete, as: :resource
  has_many :full_dumps, dependent: :destroy_async
  has_many :delta_dumps, dependent: :destroy_async
  belongs_to :previous_stream, class_name: 'Stream', optional: true

  scope :default, -> { where(status: 'default') }
  scope :active, -> { where(status: %w[active pending default previous-default]) }
  scope :pending, -> { where(status: 'pending') }
  scope :archived, -> { where(status: 'archived') }

  def display_name
    name.presence || default_name
  end

  def archive
    update(status: 'archived')
    uploads.find_each(&:archive)
  end

  def make_default
    return if default?

    Stream.transaction do
      organization.streams.default.each { |stream| stream.update(status: 'previous-default') }
      update(status: 'default')
    end
  end

  def make_pending
    return if pending?

    Stream.transaction do
      organization.streams.default.each { |stream| stream.update(status: 'active') }
      update(status: 'pending')
    end

    PromoteStreamToDefaultJob.perform_later(self)
  end

  def job_tracker_status_groups
    trackers = JobTracker.includes(:solid_queue_job).where(reports_on: self)
    needs_attention, other_trackers = trackers.partition { |x| x.status == 'error' }
    active, recent = other_trackers.partition { |x| x.status != 'complete' }

    {
      needs_attention:,
      active: active,
      recent: recent
    }
  end

  def active_jobs?
    job_tracker_status_groups.values.flatten.any?
  end

  def current_full_dump
    @current_full_dump ||= full_dumps.published.last
  end

  def interstream_delta_dumps
    delta_dumps.published.where.not(previous_stream_id: nil)
  end

  def cached_files_count
    return statistic.file_count if statistic_up_to_date?

    files.size
  end

  def cached_files_size
    return statistic.file_size if statistic_up_to_date?

    files.sum { |file| file.blob.byte_size }
  end

  def pending?
    status == 'pending'
  end

  def default?
    status == 'default'
  end

  private

  def default_name
    "#{I18n.l(created_at.to_date)} - #{I18n.l(updated_at.to_date) unless updated_at.nil? || default?}"
  end

  def statistic_up_to_date?
    return false unless statistic

    statistic.updated_at >= updated_at
  end
end
