# frozen_string_literal: true

FactoryBot.define do
  factory :full_dump do
    stream { nil }
    published_at { '2025-10-20 11:13:16' }
    normalized_dump { association(:normalized_dump, stream: stream) }
  end
end
