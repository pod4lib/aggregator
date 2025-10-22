# frozen_string_literal: true

FactoryBot.define do
  factory :allowed_consumer do
    organization { nil }
    allowed_consumable { nil }
  end
end
