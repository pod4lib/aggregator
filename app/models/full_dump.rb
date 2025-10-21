# frozen_string_literal: true

# Full dump snapshot of all records for a stream at a given time
class FullDump < ApplicationRecord
  scope :published, -> { where.not(published_at: nil) }
  belongs_to :stream
  belongs_to :normalized_dump, dependent: :destroy

  delegate :marc21, :marcxml, :deletes, :oai_xml, :errata, :record_count, to: :normalized_dump

  def deltas
    stream.delta_dumps.published.where(previous_stream_id: nil, created_at: (created_at)..)
  end

  def interstream_deltas
    stream.interstream_delta_dumps
  end
end
