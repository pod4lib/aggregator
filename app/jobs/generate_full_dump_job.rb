# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateFullDumpJob < ApplicationJob
  def self.enqueue_all
    Organization.find_each do |org|
      full_dump = org.default_stream.normalized_dumps.last
      next if full_dump && org.default_stream.uploads.where(updated_at: full_dump.last_full_dump_at...Time.zone.now).none?

      GenerateFullDumpJob.perform_later(org)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def perform(organization)
    now = Time.zone.now
    full_dump = organization.default_stream.normalized_dumps.build(last_full_dump_at: now, last_delta_dump_at: now)

    base_name = "#{organization.slug}-#{Time.zone.today}-full"
    writer = MarcRecordWriterService.new(base_name)

    begin
      hash = current_marc_records(organization.default_stream.uploads)

      organization.default_stream.uploads.each do |upload|
        upload.each_marc_record_metadata.each do |record|
          next unless hash.dig(record.marc001, 'file_id') == record.file_id || hash.dig(record.marc001, 'status') == 'delete'

          writer.write_marc_record(record)
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def human_readable_filename(base_name, file_type)
    as = case file_type
         when :deletes
           'deletes.del'
         when :marc21
           'marc21.mrc.gz'
         when :marcxml
           'marcxml.xml.gz'
         when :errata
           'errata.gz'
         else
           as
         end

    "#{base_name}-#{as}"
  end

  def current_marc_records(uploads)
    hash = {}

    uploads.each do |upload|
      upload.each_marc_record_metadata.each do |record|
        hash[record.marc001] = record.attributes.slice('file_id', 'status')
      end
    end

    hash
  end
end
