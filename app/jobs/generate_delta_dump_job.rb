# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateDeltaDumpJob < ApplicationJob
  def self.enqueue_all
    Organization.find_each { |org| GenerateDeltaDumpJob.perform_later(org) }
  end

  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    now = Time.zone.now
    full_dump = organization.default_stream.normalized_dumps.last
    return unless full_dump

    from = full_dump.last_delta_dump_at
    uploads = organization.default_stream.uploads.where(updated_at: from...now)

    return unless uploads.any?

    with_output_streams("#{organization.slug}-#{Time.zone.today}", attach_to: full_dump) do |errata_file, xml_io, binary_io|
      xmlwriter = MARC::XMLWriter.new(xml_io)

      uploads.each do |upload|
        upload.each_marc_record_metadata.each do |record|
          xmlwriter.write(record.augmented_marc)
          binary_io.write(split_marc(record.augmented_marc))
        rescue StandardError => e
          errata_file.puts("#{record['001']}: #{e}")
        end
      end
    end

    full_dump.update(last_delta_dump_at: now)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Naming/MethodParameterName
  def with_gzipped_temporary_file(name, attach_to:, as:)
    Tempfile.create(name, binmode: true) do |file|
      gzip_io = Zlib::GzipWriter.new(file)
      yield gzip_io

      gzip_io.close
      file.close
      attach_to.public_send(as).attach(io: File.open(file), filename: name)
    end
  end
  # rubocop:enable Naming/MethodParameterName

  def with_output_streams(base_name, attach_to:)
    with_gzipped_temporary_file("#{base_name}-errata.txt.gz", attach_to: attach_to, as: :errata) do |errata_file|
      with_gzipped_temporary_file("#{base_name}-marcxml.xml.gz", attach_to: attach_to, as: :delta_dump_xml) do |xml_io|
        with_gzipped_temporary_file("#{base_name}-marc21.mrc.gz", attach_to: attach_to, as: :delta_dump_binary) do |binary_io|
          yield errata_file, xml_io, binary_io
        end
      end
    end
  end

  def split_marc(marc)
    marc.to_marc
  rescue MARC::Exception => e
    return CustomMarcWriter.encode(marc) if e.message.include? "Can't write MARC record in binary format, as a length/offset"

    raise e
  end
end
