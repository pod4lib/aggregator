# frozen_string_literal: true

# :nodoc:
class Stream < ApplicationRecord
  has_paper_trail
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged scoped], scope: :organization
  belongs_to :organization
  has_many :uploads, dependent: :destroy
  has_one :default_stream_history, dependent: :destroy
  has_many :marc_records, through: :uploads, inverse_of: :stream
  has_many :files, source: :files_blobs, through: :uploads
  has_one :statistic, dependent: :delete, as: :resource
  has_many :normalized_dumps, dependent: :destroy
  has_many :job_trackers, dependent: :delete_all, as: :reports_on
  has_many :interstream_deltas, dependent: :destroy

  scope :default, -> { where(default: true) }
  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }

  has_many_attached :snapshots

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
    Stream.transaction do
      organization.streams.default.each { |stream| stream.update(default: false) }
      update(default: true)
    end
  end

  def job_tracker_status_groups
    {
      needs_attention: job_trackers.select { |jt| jt.in_retry_set? || jt.in_dead_set? },
      active: job_trackers.select { |jt| !jt.in_retry_set? && !jt.in_dead_set? }
    }
  end

  def active_jobs?
    job_tracker_status_groups.values.flatten.any?
  end

  def marc_profile
    any = false
    profile = MarcProfile.new(count: 0, histogram_frequency: {}, record_frequency: {}, sampled_values: {})

    files.find_each do |blob|
      blob_profile = MarcProfile.find_by(blob_id: blob.id)
      next unless blob_profile

      any = true
      profile.deep_merge!(blob_profile)
    end

    return unless any

    profile
  end

  def current_full_dump
    @current_full_dump ||= normalized_dumps.full_dumps.last ||
                           normalized_dumps.full_dumps.create(last_delta_dump_at: Time.zone.at(0))
  end

  private

  def default_name
    "#{I18n.l(created_at.to_date)} - #{default? ? '' : I18n.l(updated_at.to_date)}"
  end

  def check_for_a_default_stream
    return unless organization.streams.count == 1

    DefaultStreamHistory.create(organization: organization, stream: self, start_time: DateTime.now)
  end

  def update_default_stream_history
    if default
      DefaultStreamHistory.create(organization: organization, stream: self, start_time: DateTime.now)
    else
      DefaultStreamHistory.where(organization: organization, end_time: nil).update(end_time: DateTime.now)
    end
  end
end
