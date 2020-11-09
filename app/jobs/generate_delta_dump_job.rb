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

    with_gzipped_temporary_file("#{organization.slug}-marcxml") do |xml_file, xml_io|
      with_gzipped_temporary_file("#{organization.slug}-marcxml") do |binary_file, binary_io|
        xmlwriter = MARC::XMLWriter.new(xml_io)

        uploads.each do |upload|
          upload.each_marc_record_metadata.each do |record|
            xmlwriter.write(record.augmented_marc)
            binary_io.write(record.augmented_marc.to_marc)
          end
        end
        binary_io.close
        full_dump.delta_dump_binary.attach(io: File.open(binary_file), filename: "#{organization.slug}_#{Time.zone.today}.gz")

        xmlwriter.close
        full_dump.delta_dump_xml.attach(io: File.open(xml_file), filename: "#{organization.slug}_#{Time.zone.today}.xml.gz")
      end
    end

    full_dump.update(last_delta_dump_at: now)
  end
  # rubocop:enable Metrics/AbcSize

  def with_gzipped_temporary_file(name)
    Tempfile.create(name, binmode: true) do |file|
      gzip_io = Zlib::GzipWriter.new(file)
      yield file, gzip_io
    end
  end
end
