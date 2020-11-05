# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class DownloadJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    xmlfile = Tempfile.new("#{organization.slug}-marcxml")
    xmlwriter = MARC::XMLWriter.new(xmlfile)
    binary_file = Tempfile.new("#{organization.slug}-marc21", binmode: true)
    xml_compressor = Zlib::GzipWriter.new(xmlwriter)
    binary_compressor = Zlib::GzipWriter.new(binary_file)

    organization.default_stream.uploads.each do |upload|
      upload.each_marc_record_metadata.each do |record|
        xml_compressor.write(record.marc)
        binary_compressor.write(record.marc.to_marc)
      end
    end
    binary_compressor.close
    organization.full_dump_binary.attach(io: File.open(binary_file), filename: "#{organization.slug}_#{Time.zone.today}")

    xml_compressor.write('</collection>')
    xml_compressor.close
    organization.full_dump_xml.attach(io: File.open(xmlfile), filename: "#{organization.slug}_#{Time.zone.today}")
  ensure
    binary_compressor.close
    xml_compressor.close
    binary_file.close
    binary_file.unlink
    xmlfile.close
    xmlfile.unlink
  end
  # rubocop:enable Metrics/AbcSize
end
