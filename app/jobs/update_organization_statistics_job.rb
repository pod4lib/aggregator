# frozen_string_literal: true

# Calculate some daily statistics for an organization
class UpdateOrganizationStatisticsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 1

  def self.perform_all
    Organization.unscope(:order).find_each do |o|
      perform_later(o.default_stream) unless o.default_stream&.statistic&.updated_at&.today?
    end
  end

  def perform(stream)
    stream_statistics = stream.statistic || stream.create_statistic
    stream_statistics.update(date: Time.zone.today, **calculate_stream_statistics(stream))
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
