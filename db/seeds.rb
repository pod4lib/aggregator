# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require_relative '../spec/support/marc_fixture_seed_fetcher'

Upload.skip_callback(:commit, :after, :perform_extract_marc_record_metadata_job)

Settings.marc_fixture_seeds.organizations.each do |org|
  organization = Organization.create(name: org, slug: org.downcase)

  MarcFixtureSeedFetcher.fetch_uploads(org.downcase) do |upload, files|
    upload = organization.default_stream.uploads.build(name: upload['name'])
    files.map do |file|
      io = URI.open(file['download_url'], 'Authorization' => "Bearer #{Settings.marc_fixture_seeds.token}")
      upload.files.attach(io: io, filename: file['filename'])
    end
    upload.save
  end

  # Run metadata extraction job serially
  organization.uploads.each do |upload|
    ExtractMarcRecordMetadataJob.perform_now(upload)
  end
end

Upload.set_callback(:commit, :after, :perform_extract_marc_record_metadata_job)
