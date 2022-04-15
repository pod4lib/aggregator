# frozen_string_literal: true

# At-a-glance information for the POD aggregator and a single organization
class Overview
  attr_reader :organization

  def initialize(user)
    @organization = user.organization if user.present?
  end

  # total number of public organizations that provide data
  def provider_count
    providers.count
  end

  # most recent upload to default stream by any provider organization
  def last_upload
    @last_upload ||=
      Upload.includes(:organization, :stream)
          .where(organization: { provider: true, public: true })
          .where(stream: { default: true })
          .order(created_at: :desc)
          .first
  end

  # total number of MARC records in provider default streams
  def total_records
    providers.joins(:statistics).sum(:record_count)
  end

  # number of unique MARC records (by 001 field) in provider default streams
  def unique_records
    providers.joins(:statistics).sum(:unique_record_count)
  end

  # most recent 3 files uploaded to the user's organization's default stream
  def last_org_files
    return if @organization.blank?

    @organization.default_stream.files
                 .limit(3)
                 .reverse_order
                 .flat_map(&:attachments)
  end

  # active and stuck jobs for the user's organization, grouped by status
  def active_org_jobs
    return if @organization.blank?

    @organization.default_stream.job_tracker_status_groups.filter do |_status, jobs|
      jobs.count.positive?
    end
  end

  private

  # public organizations that provide data to the aggregator
  def providers
    Organization.where(provider: true, public: true)
  end
end
