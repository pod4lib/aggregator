# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateFullDumpJob < ApplicationJob
  with_job_tracking

  def self.enqueue_all
    Organization.providers.find_each do |org|
      full_dump = org.default_stream.full_dumps.published.last
      next if full_dump && org.default_stream.uploads.where(updated_at: full_dump.effective_date..).none?

      GenerateFullDumpJob.perform_later(org.default_stream)
    end
  end

  # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
  def self.enqueue_some(older_than: 4.weeks, maximum: 2)
    count = 0

    Organization.providers.find_each do |org|
      full_dump = org.default_stream.full_dumps.published.last
      next if full_dump&.effective_date&.after?(older_than.ago)
      next if full_dump && org.default_stream.uploads.where(updated_at: full_dump.effective_date..).none?

      GenerateFullDumpJob.perform_later(org.default_stream)

      if maximum
        count += 1
        break if count >= maximum
      end
    end
  end
  # rubocop:enable Metrics/AbcSize,Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
  def perform(stream, effective_date: Time.zone.now, publish: true)
    uploads = stream.uploads.active

    GenerateDeltaDumpJob.perform_now(stream, publish: publish) if stream.current_full_dump

    uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    full_dump = stream.full_dumps.build(effective_date: effective_date)
    normalized_dump = full_dump.build_normalized_dump(stream: stream)

    base_name = "#{stream.organization.slug}#{"-#{stream.slug}" unless stream.default?}-#{Time.zone.today}-full"
    writer = MarcRecordWriterService.new(base_name)
    oai_writer = ChunkedOaiMarcRecordWriterService.new(base_name, dump: normalized_dump, now: effective_date)

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(1000) do |records|
        # See note here on CPU saturation:
        # https://github.com/mperham/sidekiq/discussions/5039
        Thread.pass

        records.each do |record|
          # In a full dump, we can omit the deletes
          next if record.status == 'delete'

          writer.write_marc_record(record)
          oai_writer.write_marc_record(record)
        end
      end

      oai_writer.finalize
      writer.finalize

      writer.files.each do |as, file|
        normalized_dump.public_send(as).attach(io: File.open(file), filename: human_readable_filename(base_name, as))
      end

      normalized_dump.update(published_at: effective_date)
      full_dump.published_at = Time.zone.now if publish

      full_dump.save!

      GenerateDeltaDumpJob.perform_later(stream, from_date: effective_date, publish: publish)
    ensure
      writer.close
      writer.unlink

      oai_writer.close
      oai_writer.unlink
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity

  def human_readable_filename(base_name, file_type)
    as = case file_type
         when :deletes
           'deletes.del.txt'
         when :marc21
           'marc21.mrc.gz'
         when :marcxml
           'marcxml.xml.gz'
         else
           "#{file_type}.gz"
         end

    "#{base_name}-#{as}"
  end
end
