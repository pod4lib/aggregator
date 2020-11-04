class DownloadJob < ApplicationJob
    def perform(organization)
        file = Tempfile.new(organization.slug, binmode: true)
        organization.default_stream.uploads.each do |upload|
            upload.each_marc_record_metadata.each do |record|
                file.write(record.marc.to_marc)
            end
        end
        byebug
        file.rewind
        organization.full_dump_binary.attach(io: file, filename: "#{organization.slug}_#{Date.today}")
        file.close
    end
end