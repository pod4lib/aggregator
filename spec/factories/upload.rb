# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    organization
    after(:build) do |upload|
      upload.files.attach(
        io: File.open(
          Rails.root.join('spec/fixtures/1297245.marc')
        ),
        filename: '1297245.marc', content_type: 'application/octet-stream'
      )
    end
  end
end
