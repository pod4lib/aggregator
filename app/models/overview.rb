# frozen_string_literal: true

# At-a-glance information for the POD aggregator and a single organization
class Overview
  attr_reader :organization

  def initialize(user)
    @organization = user.organizations.first if user.present?
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
            .where(stream: { status: 'default' })
            .order(created_at: :desc)
            .first
  end

  # total number of MARC records in provider default streams
  def total_records
    providers.sum { |p| p.default_stream.statistic&.record_count || 0 }
  end

  # number of unique MARC records (by 001 field) in provider default streams
  def unique_records
    providers.sum { |p| p.default_stream.statistic&.unique_record_count || 0 }
  end

  # most recent 3 files uploaded to the user's organization's default stream
  def last_org_files
    return if @organization.blank?

    @organization.default_stream.files
                 .limit(3)
                 .reverse_order
  end

  # active and stuck jobs for the user's organization, grouped by status
  def active_org_jobs
    return if @organization.blank?

    @organization.default_stream.job_tracker_status_groups.filter do |_status, jobs|
      jobs.any?
    end
  end

  private

  # public organizations that provide data to the aggregator
  def providers
    @providers ||= Organization.where(provider: true, public: true)
  end
end
