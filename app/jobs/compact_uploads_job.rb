# frozen_string_literal: true

# Compact old Upload records into a single compacted Upload that retains only the relevant MarcRecords
# (e.g. removing duplicates across different uploads) to reduce the total number of MarcRecord objects in the database
class CompactUploadsJob < ApplicationJob
  queue_as :default

  def self.enqueue_some(ratio: 0.25, maximum: 5) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
    streams = Stream.includes(:statistic).default.select do |stream|
      next unless stream.statistic&.unique_record_count && stream.statistic.record_count

      stream.statistic.unique_record_count / stream.statistic.record_count.to_f < ratio
    end

    selected_streams = streams.sort_by do |s|
      s.upload.where(status: 'compacted').maximum(:updated_at) || Time.zone.at(0)
    end.first(maximum)

    selected_streams.each do |stream|
      perform_later(stream)
    end
  end

  # rubocop:disable Rails/SkipsModelValidations,Metrics/AbcSize,Metrics/MethodLength
  def perform(stream, age: 6.months, min_uploads: 10)
    # identify uploads that are old enough to be compacted (but leave the most recent few alone regardless of age)
    compactable_uploads = stream.uploads.active.where(created_at: ...(age.ago))
                                .where.not(id: stream.uploads.active.last(min_uploads))
                                .where.not(status: 'compacted')
    return if compactable_uploads.none?

    # find or create the "compacted" upload record to hold the result of the compacted data
    compacted_upload = stream.uploads.find_or_create_by!(status: 'compacted') do |new_upload|
      new_upload.created_at = Time.zone.at(0)
    end

    # change the upload_id for the relevant marc records and delete the rest
    NormalizedMarcRecordReader.new(compactable_uploads).current_marc_record_ids.each_slice(1000) do |slice|
      relevant_marc_records = MarcRecord.where(id: slice)

      relevant_marc_records.update_all(upload_id: compacted_upload.id)

      # clean up any duplicate MarcRecord instances on the compacted upload
      compacted_upload.marc_records
                      .where(marc001: relevant_marc_records.pluck(:marc001))
                      .where.not(id: relevant_marc_records.pluck(:id))
                      .delete_all
    end

    # do some bookkeeping
    compacted_upload.update(created_at: compactable_uploads.maximum(:created_at))

    # clean up the remaining marc records on the obsolete uploads and mark the uploads as obsolete
    compactable_uploads.find_each do |upload|
      upload.update(compacted_upload_id: compacted_upload.id, status: 'obsolete')
      upload.marc_records.delete_all
    end
  end
  # rubocop:enable Rails/SkipsModelValidations,Metrics/AbcSize,Metrics/MethodLength
end
