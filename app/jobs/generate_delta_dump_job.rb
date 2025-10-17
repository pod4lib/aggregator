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
    writer = MarcRecordWriterService.new(base_name, dump: delta_dump, now: now)

    begin
      NormalizedMarcRecordReader.new(uploads).each_slice(1000) do |records|
        # See note here on CPU saturation:
        # https://github.com/mperham/sidekiq/discussions/5039
        Thread.pass

        records.each do |record|
          if record.status == 'delete'
            writer.write_delete(record)
          else
            writer.write_marc_record(record)
          end
        end

        progress.increment(records.length)
      end

      writer.finalize

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
end
