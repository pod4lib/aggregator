# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class ExtractMarcRecordMetadataJob < ApplicationJob
  queue_as :default

  def perform(upload)
    upload.with_lock do
      upload.marc_records.delete_all

      upload.each_marc_record_metadata.each_slice(100) do |batch|
        # rubocop:disable Rails/SkipsModelValidations
        MarcRecord.insert_all(batch.map { |x| x.attributes.except('id') }, returning: false)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    UpdateOrganizationStatisticsJob.perform_later(upload.organization, upload.stream)
  end
end
