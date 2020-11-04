# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    after(:create, &:confirm)
  end

  factory :admin, parent: :user do
    sequence(:email) { |n| "admin-#{n}@example.com" }
    after(:create) do |user|
      user.add_role(:admin)
      user.confirm
    end
  end
end
