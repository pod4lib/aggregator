# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    organization

    trait :binary_marc do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/1297245.marc')
          ),
          filename: '1297245.marc', content_type: 'application/marc'
        )
      end
    end

    trait :binary_marc_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/1297245.marc.gz')
          ),
          filename: '1297245.marc.gz', content_type: 'application/octet-stream'
        )
      end
    end

    trait :marc_xml do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/12345.marcxml')
          ),
          filename: '1297245.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :deleted_binary_marc do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/deleted.marc')
          ),
          filename: 'deleted.marc', content_type: 'application/marc'
        )
      end
    end

    trait :deleted_marc_xml do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/deleted.marcxml')
          ),
          filename: 'deleted.marcxml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :long_file do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/long-record.xml')
          ),
          filename: 'long-record.xml', content_type: 'application/marcxml+xml'
        )
      end
    end

    trait :multple_files do
      after(:build) do |upload|
        upload.files.attach([
                              {
                                io: File.open(
                                  Rails.root.join('spec/fixtures/1297245.marc')
                                ),
                                filename: '1297245.mrc', content_type: 'application/marc'
                              },
                              {
                                io: File.open(
                                  Rails.root.join('spec/fixtures/12345.marcxml')
                                ),
                                filename: '1297245.marcxml', content_type: 'application/marcxml+xml'
                              }
                            ])
      end
    end

    trait :marc21_multi_record do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/9953670.marc')
          ),
          filename: '9953670.marc', content_type: 'application/marc'
        )
      end
    end

    trait :small_batch_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/stanford-50.mrc.gz')
          ),
          filename: 'stanford-50.mrc.gz', content_type: 'application/octet-stream'
        )
      end
    end

    trait :deletes do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/deletes.txt')
          ),
          filename: 'deletes.txt', content_type: 'text/plain'
        )
      end
    end

    trait :tar_gz do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/multifile-tar-gz.tar.gz')
          ),
          filename: 'multifile-tar-gz.tar', content_type: 'application/octet-stream'
        )
      end
    end

    trait :mixed_file_with_tar_gz do
      after(:build) do |upload|
        upload.files.attach([
                              {
                                io: File.open(
                                  Rails.root.join('spec/fixtures/1297245.marc')
                                ),
                                filename: '1297245.mrc', content_type: 'application/marc'
                              },
                              {
                                io: File.open(
                                  Rails.root.join('spec/fixtures/multifile-tar-gz.tar.gz')
                                ),
                                filename: 'multifile-tar-gz.tar', content_type: 'application/octet-stream'
                              }
                            ])
      end
    end
  end
end
