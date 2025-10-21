# frozen_string_literal: true

# :nodoc:
class NormalizedDump < ApplicationRecord
  belongs_to :stream
  has_one :organization, through: :stream

  has_one_attached :marc21
  has_one_attached :marcxml
  has_many_attached :oai_xml
  has_one_attached :deletes
  has_many_attached :errata

  def record_count
    if marc21&.attachment&.metadata
      # Use marc21 as the source of the record count. marcxml count may differ.
      marc21.attachment.metadata['count']
    else
      0
    end
  end
end
