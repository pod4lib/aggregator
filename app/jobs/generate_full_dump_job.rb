# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateFullDumpJob < ApplicationJob
  with_job_tracking

  def self.enqueue_all
    Organization.find_each do |org|
      full_dump = org.default_stream.normalized_dumps.last
      next if full_dump && org.default_stream.uploads.where(updated_at: full_dump.last_full_dump_at...Time.zone.now).none?

      GenerateFullDumpJob.perform_later(org)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
  def perform(organization)
    now = Time.zone.now
    uploads = Upload.active.where(stream: organization.default_stream)

    uploads.where.not(status: 'processed').each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    progress.total = uploads.sum(&:marc_records_count)

    full_dump = organization.default_stream.normalized_dumps.build(last_full_dump_at: now, last_delta_dump_at: now)

    base_name = "#{organization.slug}-#{Time.zone.today}-full"
    writer = MarcRecordWriterService.new(base_name)
    oai_file_counter = 0

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(100) do |records|
        records.each_slice(10) do |record_chunk|
          oai_writer = OaiMarcRecordWriterService.new(base_name)
          record_chunk.each do |record|
            # In a full dump, we can omit the deletes
            next if record.status == 'delete'

            writer.write_marc_record(record)
            oai_writer.write_marc_record(record)
          end
          oai_writer.finalize
          full_dump.public_send(:oai_xml).attach(io: File.open(oai_writer.oai_file),
                                                 filename: human_readable_filename(
                                                   base_name, "oai_xml-#{format('%010d', oai_file_counter)}"
                                                 ))

          oai_file_counter += 1
          progress.increment(records.length)
        end
      end

      writer.finalize

      writer.files.each do |as, file|
        full_dump.public_send(as).attach(io: File.open(file), filename: human_readable_filename(base_name, as))
      end

      full_dump.save!

      GenerateDeltaDumpJob.perform_later(organization)
    ensure
      writer.close
      writer.unlink
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
