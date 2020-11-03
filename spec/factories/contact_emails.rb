# frozen_string_literal: true

FactoryBot.define do
  factory :contact_email do
    email { 'test@example.com' }
    organization { nil }
    confirmation_token { '12345' }
    confirmation_sent_at { '2020-11-03 09:11:19' }
  end
end
