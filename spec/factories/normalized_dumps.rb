# frozen_string_literal: true

FactoryBot.define do
  factory :normalized_dump do
    stream { nil }
    last_full_dump_at { '2020-11-06 08:11:56' }
    last_delta_dump_at { '2020-11-06 08:11:56' }
    published_at { '2020-11-06 08:11:56' }
  end
end
