# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class GenerateFullDumpJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    now = Time.zone.now
    full_dump = organization.default_stream.normalized_dumps.build(last_full_dump_at: now, last_delta_dump_at: now)

    with_gzipped_temporary_file("#{organization.slug}-marcxml") do |xml_file, xml_io|
      with_gzipped_temporary_file("#{organization.slug}-marcxml") do |binary_file, binary_io|
        xmlwriter = MARC::XMLWriter.new(xml_io)

        organization.default_stream.uploads.each do |upload|
          upload.each_marc_record_metadata.each do |record|
            xmlwriter.write(record.marc)
            binary_io.write(record.marc.to_marc)
          end
        end

        binary_io.close
        full_dump.full_dump_binary.attach(io: File.open(binary_file), filename: "#{organization.slug}_#{Time.zone.today}.gz")

        xmlwriter.close
        full_dump.full_dump_xml.attach(io: File.open(xml_file), filename: "#{organization.slug}_#{Time.zone.today}.xml.gz")
      end
    end

    full_dump.save!
  end
  # rubocop:enable Metrics/AbcSize

  def with_gzipped_temporary_file(name)
    Tempfile.create(name, binmode: true) do |file|
      gzip_io = Zlib::GzipWriter.new(file)
      yield file, gzip_io
    end
  end
end
