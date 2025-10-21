# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "A group of organizations #{n}" }
    sequence(:short_name) { |n| "Group#{n}" }
    sequence(:slug) { |n| "group-#{n}" }
    factory :group_with_organizations do
      after(:create) do |group|
        group.organizations << create_list(:organization, 3)
      end
    end
  end
end
