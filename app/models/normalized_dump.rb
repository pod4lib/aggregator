# frozen_string_literal: true

# :nodoc:
class NormalizedDump < ApplicationRecord
  scope :full_dumps, -> { where(full_dump_id: nil) }
  scope :published, -> { where.not(published_at: nil) }

  belongs_to :stream
  has_one :organization, through: :stream
  has_many :deltas, class_name: 'NormalizedDump', foreign_key: 'full_dump_id', inverse_of: :full_dump, dependent: :destroy
  belongs_to :full_dump, class_name: 'NormalizedDump', optional: true
  has_one :interstream_delta, dependent: :destroy

  has_one_attached :marc21
  has_one_attached :marcxml
  has_many_attached :oai_xml
  has_one_attached :deletes
  has_many_attached :errata

  def record_count
    if marc21&.attachment && marc21.attachment.metadata
      # Use marc21 as the source of the record count. marcxml count may differ.
      marc21.attachment.metadata['count']
    else
      0
    end
  end
end
