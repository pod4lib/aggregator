# frozen_string_literal: true

FactoryBot.define do
  factory :default_stream_history do
    organization { nil }
    stream_id { nil }
    start_time { '2022-04-15 13:29:21' }
    end_time { '2022-04-15 13:30:21' }
  end
end
