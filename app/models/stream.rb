# frozen_string_literal: true

# :nodoc:
class Stream < ApplicationRecord
  has_paper_trail
  extend FriendlyId

  friendly_id :name, use: %i[finders slugged scoped], scope: :organization
  belongs_to :organization
  has_many :uploads, dependent: :destroy_async
  has_many :default_stream_histories, dependent: :delete_all
  has_many :marc_records, through: :uploads, inverse_of: :stream
  has_many :files, source: :files_attachments, through: :uploads
  has_one :statistic, dependent: :delete, as: :resource
  has_many :full_dumps, dependent: :destroy_async
  has_many :delta_dumps, dependent: :destroy_async
  has_many :job_trackers, dependent: :delete_all, as: :reports_on

  scope :default, -> { where(default: true) }
  scope :previous_default, -> { joins(:default_stream_histories).where(default: false).distinct }
  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }

  after_create :check_for_a_default_stream

  before_update :update_default_stream_history, if: :default_changed?

  def display_name
    name.presence || default_name
  end

  def archive
    update(status: 'archived', default: false)
    uploads.find_each(&:archive)
  end

  def make_default
    return if default

    Stream.transaction do
      organization.streams.default.each { |stream| stream.update(default: false) }
      update(default: true)
    end
  end

  def job_tracker_status_groups
    {
      needs_attention: job_trackers.order(created_at: :desc).select(&:error_processing?),
      active: job_trackers.order(created_at: :desc).select { |jt| jt.sidekiq_status == 'active' }
    }
  end

  def active_jobs?
    job_tracker_status_groups.values.flatten.any?
  end

  def current_full_dump
    @current_full_dump ||= full_dumps.published.last
  end

  def cached_files_count
    return statistic.file_count if statistic_up_to_date?

    files.size
  end

  def cached_files_size
    return statistic.file_size if statistic_up_to_date?

    files.sum { |file| file.blob.byte_size }
  end

  private

  def default_name
    "#{I18n.l(created_at.to_date)} - #{I18n.l(updated_at.to_date) unless default?}"
  end

  def check_for_a_default_stream
    return unless organization.streams.one?

    DefaultStreamHistory.create(stream: self, start_time: DateTime.now)
  end

  def update_default_stream_history
    if default
      DefaultStreamHistory.create(stream: self, start_time: DateTime.now)
    else
      organization.default_stream_histories.where(end_time: nil).update(end_time: DateTime.now)
    end
  end

  def statistic_up_to_date?
    return false unless statistic

    statistic.updated_at >= updated_at
  end
end
