# frozen_string_literal: true

# Calculate some daily statistics for an organization
class UpdateOrganizationStatisticsJob < ApplicationJob
  queue_as :default

  def self.perform_all
    Organization.find_each { |o| perform_later(o) }
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def perform(organization, stream = nil, upload = nil)
    stream ||= organization.default_stream

    # short-circuit if our statistics job is already obsolete
    return if upload && stream.uploads.where('created_at > ?', upload.created_at).any?

    # short-circuit if the stream's statistics have already been updated today
    return if stream&.statistic&.updated_at&.today?

    generate_statistics!(organization, stream)
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def generate_statistics!(organization, stream)
    stream_statistics = stream.statistic || stream.create_statistic
    stream_statistics.update(date: Time.zone.today, **calculate_stream_statistics(stream))

    # We need to reload the resource so that the organization stats
    # include the latest calculated default_stream.statistics.
    organization.reload

    org_statistics = organization.statistics.find_or_create_by(date: Time.zone.today)

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
      file_size: context.files.sum { |file| file.blob.byte_size },
      file_count: context.files.size
    }
  end
end
