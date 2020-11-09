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
          filename: '1297245.mrc', content_type: 'application/octet-stream'
        )
      end
    end

    trait :marc_xml do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/12345.marcxml')
          ),
          filename: '1297245.marcxml', content_type: 'application/xml'
        )
      end
    end

    trait :long_file do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/long-record.xml')
          ),
          filename: 'long-record.xml', content_type: 'application/xml'
        )
      end
    end

    trait :multple_files do
      after(:build) do |upload|
        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/1297245.marc')
          ),
          filename: '1297245.mrc', content_type: 'application/octet-stream'
        )

        upload.files.attach(
          io: File.open(
            Rails.root.join('spec/fixtures/12345.marcxml')
          ),
          filename: '1297245.marcxml', content_type: 'application/xml'
        )
      end
    end
  end
end
