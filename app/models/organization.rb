# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  resourcify
  friendly_id :name, use: :slugged
end
