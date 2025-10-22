# frozen_string_literal: true

##
# Background job to create a delta dump download for a resource (organization)
class GenerateDeltaDumpJob < ApplicationJob
  with_job_tracking

  def self.enqueue_all
    Organization.providers.find_each { |org| GenerateDeltaDumpJob.perform_later(org.default_stream) }
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def perform(stream, from_date: nil, effective_date: Time.zone.now, publish: true)
    full_dump = stream.current_full_dump

    return unless full_dump

    from_date ||= [stream.delta_dumps.published.maximum(:effective_date), full_dump.effective_date].compact.max

    uploads = stream.uploads.active.where(created_at: from_date...effective_date)

    return unless uploads.any?

    uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    progress.total = uploads.sum(&:marc_records_count)

    delta_dump = stream.delta_dumps.build(effective_date: effective_date)
    normalized_dump = delta_dump.build_normalized_dump(stream: stream)

    base_name = "#{stream.organization.slug}#{"-#{stream.slug}" unless stream.default}-#{effective_date}-delta"
    writer = MarcRecordWriterService.new(base_name)
    oai_writer = ChunkedOaiMarcRecordWriterService.new(base_name, dump: normalized_dump, now: effective_date)

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(1000) do |records|
        # See note here on CPU saturation:
        # https://github.com/mperham/sidekiq/discussions/5039
        Thread.pass

        records.each do |record|
          if record.status == 'delete'
            writer.write_delete(record)
            oai_writer.write_delete(record)
          else
            writer.write_marc_record(record)
            oai_writer.write_marc_record(record)
          end
        end

        progress.increment(records.length)
      end

      writer.finalize
      oai_writer.finalize

      writer.files.each do |as, file|
        normalized_dump.public_send(as).attach(io: File.open(file),
                                               filename: human_readable_filename(base_name, as))
      end

      normalized_dump.update(published_at: effective_date)
      delta_dump.published_at = Time.zone.now if publish

      delta_dump.save!
    ensure
      writer.close
      writer.unlink

      oai_writer.close
      oai_writer.unlink
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

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
