# frozen_string_literal: true

FactoryBot.define do
  factory :stream do
    factory :stream_with_uploads do
      after(:create) do |stream|
        create_list(:upload, :binary_marc, stream: stream)
      end
    end
  end
end
