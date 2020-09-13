# frozen_string_literal: true

# :nodoc:
class Batch < ApplicationRecord
  has_paper_trail
  belongs_to :stream
  has_one :organization, through: :stream

  has_one_attached :changes
  has_one_attached :deletes
end
