# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default
  with_job_tracking

  # rubocop:disable Metrics/AbcSize
  def perform(upload)
    progress.total = 0

    upload.with_lock do
      upload.marc_records.delete_all

      upload.each_marc_record_metadata.each_slice(100) do |batch|
        progress.increment(batch.size)

        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    UpdateOrganizationStatisticsJob.perform_later(upload.organization, upload.stream)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def update_job_tracker_properties(tracker)
    super
    upload = arguments.first
    tracker.resource = upload
    tracker.reports_on = upload&.stream
  end
end
