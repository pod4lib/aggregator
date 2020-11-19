# frozen_string_literal: true

FactoryBot.define do
  factory :job_tracker do
    resource { nil }
    job_id { 'MyString' }
    job_class { 'MyString' }
  end
end
