# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
end
