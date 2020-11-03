# frozen_string_literal: true

FactoryBot.define do
  factory :marc_record do
    file_id { nil }
    marc001 { 'MyString' }
  end
end
