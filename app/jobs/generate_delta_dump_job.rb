# frozen_string_literal: true

##
# Background job to create a delta dump download for a resource (organization)
class GenerateDeltaDumpJob < ApplicationJob
  with_job_tracking

  def self.enqueue_all
    Organization.providers.find_each { |org| GenerateDeltaDumpJob.perform_later(org) }
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def perform(organization, publish: true)
    now = Time.zone.now
    full_dump = organization.default_stream.current_full_dump

    return unless full_dump

    from = full_dump.last_delta_dump_at

    uploads = organization.default_stream.uploads.active.where(created_at: from...now)

    return unless uploads.any?

    uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    progress.total = uploads.sum(&:marc_records_count)

    delta_dump = full_dump.deltas.create(stream_id: full_dump.stream_id)
    base_name = "#{organization.slug}-#{Time.zone.today}-delta"
    writer = MarcRecordWriterService.new(base_name)
    oai_file_counter = 0

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(Settings.oai_max_page_size) do |records|
        # See note here on CPU saturation:
        # https://github.com/mperham/sidekiq/discussions/5039
        Thread.pass

        oai_writer = OaiMarcRecordWriterService.new(base_name)
        records.each do |record|
          if record.status == 'delete'
            writer.write_delete(record)
            oai_writer.write_delete(record, now)
          else
            writer.write_marc_record(record)
            oai_writer.write_marc_record(record, now)
          end
        end
        oai_writer.finalize
        delta_dump.oai_xml.attach(io: File.open(oai_writer.oai_file),
                                  filename: human_readable_filename(base_name, :oai_xml, oai_file_counter))

        oai_file_counter += 1
        # Save the dump once for every 100 oai files to free up file handles
        delta_dump.save! if (oai_file_counter % 100).zero?
        progress.increment(records.length)
      ensure
        oai_writer.close
        oai_writer.unlink
      end

      writer.finalize

      writer.files.each do |as, file|
        delta_dump.public_send(as).attach(io: File.open(file),
                                          filename: human_readable_filename(base_name, as))
      end

      # Add a timestamp when the dump is saved at the end of the job to indicate
      # it is complete and ready for harvesting.
      delta_dump.published_at = Time.zone.now if publish
      delta_dump.save!
      full_dump.update(last_delta_dump_at: now)
    ensure
      writer.close
      writer.unlink
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
