# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default
  with_job_tracking

  # rubocop:disable Metrics/AbcSize
  def perform(upload)
    return unless upload.active? && upload.files.any?

    upload.with_lock do
      upload.update(status: 'active')

      upload.marc_records.delete_all

      total = 0
      deletes = 0
      upload.read_marc_record_metadata.each_slice(100) do |batch|
        batch_deletes = batch.count { |x| x.status == 'delete' }
        total += batch.count - batch_deletes
        deletes += batch_deletes

        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end

      upload.update(status: 'processed', marc_records_count: total, deletes_count: deletes)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
