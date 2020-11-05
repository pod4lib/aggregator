# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class DownloadJob < ApplicationJob
  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    file = Tempfile.new(organization.slug, binmode: true)
    organization.default_stream.uploads.each do |upload|
      upload.each_marc_record_metadata.each do |record|
        file.write(record.marc.to_marc)
      end
    end
    file.rewind
    organization.full_dump_binary.attach(io: file, filename: "#{organization.slug}_#{Time.zone.today}")
  ensure
    file.close
    file.unlink
  end
  # rubocop:enable Metrics/AbcSize
end
