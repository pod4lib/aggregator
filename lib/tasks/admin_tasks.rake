# frozen_string_literal: true

require_relative '../../spec/support/marc_fixture_seed_fetcher'

namespace :agg do
  desc 'Create an initial admin user'
  task create_admin: :environment do
    puts 'Creating an initial admin user.'
    u = prompt_to_create_user

    u.add_role(:admin)
    u.confirm
    puts 'User created.'
  end

  def prompt_to_create_user
    User.find_or_create_by!(email: prompt_for_email) do |u|
      puts 'User not found. Enter a password to create the user.'
      u.password = prompt_for_password
    end
  rescue StandardError => e
    puts e
    retry
  end

  def prompt_for_email
    print 'Email: '
    $stdin.gets.chomp
  end

  def prompt_for_password
    begin
      system 'stty -echo'
      print 'Password (must be 8+ characters): '
      password = $stdin.gets.chomp
      puts "\n"
    ensure
      system 'stty echo'
    end
    password
  end

  desc 'Seed data from Aggregator API'
  task seed_from_api: :environment do
    Upload.skip_callback(:commit, :after, :perform_extract_marc_record_metadata_job)

    puts "Seeding data from Aggregator @ #{Settings.marc_fixture_seeds.host} (this may take a several minutes)"
    Settings.marc_fixture_seeds.organizations.each do |org|
      puts "Fetching data from #{org}"
      organization = Organization.create(name: org, slug: org.downcase)

      file_count = 0
      MarcFixtureSeedFetcher.fetch_uploads(org.downcase) do |upload, files|
        upload = organization.default_stream.uploads.build(name: upload['name'])
        files.map do |file|
          file_count += 1
          puts "Uploading file #{file['filename']} (#{file['download_url']})"
          uri = URI.parse(file['download_url'])
          io = uri.open('Authorization' => "Bearer #{Settings.marc_fixture_seeds.token}")
          upload.files.attach(io: io, filename: file['filename'])
        end
        upload.save
      end

      puts "Extracting metadata from #{file_count} files seeded from #{org}"
      # Run metadata extraction job serially
      organization.uploads.each do |upload|
        ExtractMarcRecordMetadataJob.perform_now(upload)
      end
    end

    Upload.set_callback(:commit, :after, :perform_extract_marc_record_metadata_job)
  end
end
