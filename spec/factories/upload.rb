# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    organization

    trait :binary_marc do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/1297245.marc').open,
          filename: '1297245.marc', content_type: 'application/marc'
        )
      end
    end

    trait :binary_marc_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/1297245.marc.gz').open,
          filename: '1297245.marc.gz', content_type: 'application/octet-stream'
        )
      end
    end

    trait :marc_xml do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/12345.marcxml').open,
          filename: '12345.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :marc_xml2 do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/67890.marcxml').open,
          filename: '67890.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :marc_xml3 do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/75163.marcxml').open,
          filename: '75163.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :deleted_binary_marc do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/deleted.marc').open,
          filename: 'deleted.marc', content_type: 'application/marc'
        )
      end
    end

    trait :deleted_marc_xml do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/deleted.marcxml').open,
          filename: 'deleted.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :long_file do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/long-record.xml').open,
          filename: 'long-record.xml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :invalid_marc do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/bad_marc8.mrc').open,
          filename: 'bad_marc8.marc', content_type: 'application/marc'
        )
      end
    end

    trait :multiple_files do
      after(:build) do |upload|
        upload.files.attach([
                              {
                                io: Rails.root.join('spec/fixtures/1297245.marc').open,
                                filename: '1297245.mrc', content_type: 'application/marc'
                              },
                              {
                                io: Rails.root.join('spec/fixtures/12345.marcxml').open,
                                filename: '1297245.marcxml', content_type: 'application/marcxml+xml'
                              }
                            ])
      end
    end

    trait :marc21_multi_record do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/9953670.marc').open,
          filename: '9953670.marc', content_type: 'application/marc'
        )
      end
    end

    trait :small_batch_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/stanford-50.mrc.gz').open,
          filename: 'stanford-50.mrc.gz', content_type: 'application/octet-stream'
        )
      end
    end

    trait :deletes do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/deletes.txt').open,
          filename: 'deletes.txt', content_type: 'text/plain'
        )
      end
    end

    trait :tar_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/multifile-tar-gz.tar.gz').open,
          filename: 'multifile-tar-gz.tar', content_type: 'application/octet-stream'
        )
      end
    end

    trait :mixed_file_with_tar_gz do
      after(:build) do |upload|
        upload.files.attach([
                              {
                                io: Rails.root.join('spec/fixtures/1297245.marc').open,
                                filename: '1297245.mrc', content_type: 'application/marc'
                              },
                              {
                                io: Rails.root.join('spec/fixtures/multifile-tar-gz.tar.gz').open,
                                filename: 'multifile-tar-gz.tar', content_type: 'application/octet-stream'
                              }
                            ])
      end
    end

    trait :alma_marc_xml_ish do
      after(:build) do |upload|
        upload.files.attach(
          io: Rails.root.join('spec/fixtures/not.marcxml').open,
          filename: 'not.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end
  end
end
