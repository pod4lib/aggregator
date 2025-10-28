# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default
  with_job_tracking

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def perform(upload)
    return unless upload.active? && upload.files.any?

    progress.total = 0

    upload.with_lock do
      upload.update(status: 'active')

      upload.marc_records.delete_all

      total = 0
      deletes = 0
      upload.read_marc_record_metadata.each_slice(100) do |batch|
        progress.increment(batch.size)

        batch_deletes = batch.count { |x| x.status == 'delete' }
        total += batch.count - batch_deletes
        deletes += batch_deletes

        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end

      upload.update(status: 'processed', marc_records_count: total, deletes_count: deletes)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def update_job_tracker_properties(tracker)
    super
    upload = arguments.first
    tracker.resource = upload
    tracker.reports_on = upload&.stream
  end
end
