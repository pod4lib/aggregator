# frozen_string_literal: true

# :nodoc:
class InterstreamDelta < ApplicationRecord
  belongs_to :normalized_dump
  has_one :stream, through: :normalized_dump, inverse_of: :interstream_deltas

  has_one_attached :marc21
  has_one_attached :marcxml
  has_one_attached :deletes
end
