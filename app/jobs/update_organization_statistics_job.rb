# frozen_string_literal: true

# Calculate some daily statistics for an organization
class UpdateOrganizationStatisticsJob < ApplicationJob
  queue_as :default

  def self.perform_all
    Organization.find_each { |o| perform_later(o) }
  end

  def perform(organization, stream = nil)
    stream ||= organization.default_stream

    stream_statistics = stream.statistic || stream.create_statistic
    stream_statistics.update(date: Time.zone.today, **calculate_stream_statistics(stream))

    org_statistics = organization.statistics.find_or_initialize_by(date: Time.zone.today)

    org_statistics.update(
      date: Time.zone.today,
      **calculate_organization_statistics(organization)
    )
  end

  def calculate_organization_statistics(context)
    {
      unique_record_count: context.marc_records.distinct.count(:marc001),
      record_count: context.marc_records.size,
      file_count: context.default_stream&.statistic&.file_count,
      file_size: context.default_stream&.statistic&.file_size
    }
  end

  def calculate_stream_statistics(context)
    {
      unique_record_count: context.marc_records.distinct.count(:marc001),
      record_count: context.marc_records.size,
      file_size: context.files.sum(:byte_size),
      file_count: context.files.size
    }
  end
end
