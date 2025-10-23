# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default
  with_job_tracking

  def perform(upload)
    return unless upload.active? && upload.files.any?

    upload.with_lock do
      upload.update(status: 'active')

      upload.marc_records.delete_all

      total = 0
      upload.read_marc_record_metadata.each_slice(100) do |batch|
        total += batch.size

        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end

      upload.update(status: 'processed', marc_records_count: total)
    end

    # For now, do no start an UpdateOrganizationStatisticsJob,
    # until we resolve: https://github.com/pod4lib/aggregator/issues/975
    # UpdateOrganizationStatisticsJob.perform_later(upload.organization, upload.stream, upload)
  end
end
