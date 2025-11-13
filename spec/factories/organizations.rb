# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:slug) { |n| "org-#{n}" }

    trait :consumer do
      provider { false }
    end

    trait :unrestricted do
      restrict_downloads { false }
    end
  end
end
