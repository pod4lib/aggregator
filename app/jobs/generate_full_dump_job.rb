# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateFullDumpJob < ApplicationJob
  with_job_tracking

  def self.enqueue_all
    Organization.providers.find_each do |org|
      full_dump = org.default_stream.normalized_dumps.published.last
      next if full_dump && org.default_stream.uploads.where(updated_at: full_dump.last_full_dump_at...Time.zone.now).none?

      GenerateFullDumpJob.perform_later(org)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def perform(organization, publish: true)
    now = Time.zone.now
    uploads = Upload.active.where(stream: organization.default_stream)

    uploads.where.not(status: 'processed').find_each do |upload|
      ExtractMarcRecordMetadataJob.perform_now(upload)
    end

    progress.total = uploads.sum(&:marc_records_count)

    full_dump = organization.default_stream.normalized_dumps.build(last_full_dump_at: now, last_delta_dump_at: now)

    base_name = "#{organization.slug}-#{Time.zone.today}-full"
    writer = MarcRecordWriterService.new(base_name, dump: full_dump, now: now)

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(1000) do |records|
        # See note here on CPU saturation:
        # https://github.com/mperham/sidekiq/discussions/5039
        Thread.pass

        records.each do |record|
          # In a full dump, we can omit the deletes
          next if record.status == 'delete'

          writer.write_marc_record(record)
        end

        progress.increment(records.length)
      end

      writer.finalize

      # Add a timestamp when the dump is saved at the end of the job to indicate
      # it is complete, should supercede the previous full dump, and is ready for harvesting.
      full_dump.published_at = Time.zone.now if publish
      full_dump.save!

      GenerateDeltaDumpJob.perform_later(organization, publish: publish)
    ensure
      writer.close
      writer.unlink
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
