# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class DownloadJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    xmlfile = Tempfile.new("#{organization.slug}-marcxml")
    xmlwriter = MARC::XMLWriter.new(xmlfile)
    file = Tempfile.new("#{organization.slug}-marc21", binmode: true)
    organization.default_stream.uploads.each do |upload|
      upload.each_marc_record_metadata.each do |record|
        file.write(record.marc.to_marc)
        xmlwriter.write(record.marc)
      end
    end
    file.rewind
    organization.full_dump_binary.attach(io: file, filename: "#{organization.slug}_#{Time.zone.today}")

    # we would use xmlwriter#close, but it annoyingly also closes the file handle on us..
    xmlfile.write('</collection>')
    xmlfile.rewind
    organization.full_dump_xml.attach(io: xmlfile, filename: "#{organization.slug}_#{Time.zone.today}")
  ensure
    file.close
    file.unlink
    xmlfile.close
    xmlfile.unlink
  end
  # rubocop:enable Metrics/AbcSize
end
