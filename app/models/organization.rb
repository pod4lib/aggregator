# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy

  def default_stream
    @default_stream ||= streams.find_or_create_by(default: true)
  end
end
