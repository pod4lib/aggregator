# frozen_string_literal: true

##
# Background job to create a delta dump download for a resource (organization)
class GenerateInterstreamDeltaDumpJob < ApplicationJob
  with_job_tracking

  def perform(previous_stream, stream, effective_date: Time.zone.now, publish: true) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    raise ArgumentError, 'Previous stream cannot be the same as the current stream' if previous_stream == stream

    previous_uploads = previous_stream.uploads.active.where(created_at: ..effective_date)
    new_uploads = stream.uploads.active.where(created_at: ..effective_date)

    previous_uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    new_uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    interstream_delta = stream.delta_dumps.find_or_initialize_by(stream: stream,
                                                                 previous_stream: previous_stream,
                                                                 effective_date: effective_date)
    normalized_dump = interstream_delta.build_normalized_dump(stream: stream)

    base_name = "#{stream.organization.slug}-#{stream.slug}-#{Time.zone.today}-interstream-delta-#{previous_stream.slug}"
    writer = MarcRecordWriterService.new(base_name, dump: normalized_dump, now: effective_date)

    job_tracker.update(total: previous_uploads.sum(&:marc_records_count))

    NormalizedMarcRecordReader.new(previous_uploads).each_slice(200) do |previous_records|
      current_records = NormalizedMarcRecordReader.new(new_uploads, augment_marc: false,
                                                                    conditions: { marc001: previous_records.map(&:marc001) })

      previous_records_by_marc001 = previous_records.index_by(&:marc001)
      deleted_records = previous_records_by_marc001.keys - current_records.map(&:marc001)

      deleted_records.each do |marc001|
        writer.write_delete(previous_records_by_marc001[marc001])
      end

      new_records = current_records.reject do |record|
        previous_records_by_marc001[record.marc001].nil? ||
          previous_records_by_marc001[record.marc001].checksum == record.checksum
      end

      new_records.each do |new_record|
        next if new_record.status == 'delete'

        writer.write_marc_record(new_record)
      end

      job_tracker.increment(previous_records.size)
    end

    writer.finalize
    normalized_dump.update(published_at: effective_date)
    interstream_delta.published_at = Time.zone.now if publish

    interstream_delta.save!
  ensure
    writer.close
    writer.unlink
  end

  private

  def human_readable_filename(base_name, file_type, counter = nil)
    as = case file_type
         when :deletes
           'deletes.del.txt'
         when :marc21
           'marc21.mrc.gz'
         when :marcxml
           'marcxml.xml.gz'
         when :oai_xml
           "oai-#{format('%010d', counter)}.xml.gz"
         else
           "#{file_type}.gz"
         end

    "#{base_name}-#{as}"
  end
end
