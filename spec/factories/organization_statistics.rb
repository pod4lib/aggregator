# frozen_string_literal: true

FactoryBot.define do
  factory :organization_statistic do
    organization { nil }
    unique_record_count { '' }
    record_count { '' }
    file_size { '' }
    file_count { '' }
    date { '2020-11-05' }
  end
end
