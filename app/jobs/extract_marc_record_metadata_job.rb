# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default
  with_job_tracking

  def perform(upload) # rubocop:disable Metrics/AbcSize
    return unless upload.active? && upload.files.any?

    upload.with_lock do
      upload.update(status: 'active')

      upload.marc_records.delete_all

      total = 0
      job_tracker.update(total: total)
      upload.read_marc_record_metadata.each_slice(100) do |batch|
        total += batch.size

        job_tracker.increment(batch.size)

        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end

      job_tracker.update(progress: total, total: total)

      upload.update(status: 'processed', marc_records_count: total)
    end
  end
end
