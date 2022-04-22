# frozen_string_literal: true

# :nodoc:
class NormalizedDump < ApplicationRecord
  scope :full_dumps, -> { where(full_dump_id: nil) }

  belongs_to :stream
  has_one :organization, through: :stream
  has_many :deltas, class_name: 'NormalizedDump', foreign_key: 'full_dump_id', inverse_of: :full_dump, dependent: :destroy
  belongs_to :full_dump, class_name: 'NormalizedDump', optional: true

  has_one_attached :marc21
  has_one_attached :marcxml
  has_one_attached :deletes
  has_many_attached :errata

  # Seems to make sense to attach these to a full-dump, because 
  # updating a full-dump will mean they need to be recalculated
  has_one_attached :interstream_delta_additions
  has_one_attached :interstream_delta_deletions
end
