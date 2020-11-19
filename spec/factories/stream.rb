# frozen_string_literal: true

FactoryBot.define do
  factory :stream do
    factory :stream_with_uploads do
      after(:create) do |stream, options = { count: 1 }|
        create_list(:upload, options[:count], :binary_marc, stream: stream)
      end
    end
  end
end
