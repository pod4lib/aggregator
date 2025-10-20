# frozen_string_literal: true

# Delta dump snapshot of changed records in a stream (or across a stream) at a given time
class DeltaDump < ApplicationRecord
  scope :published, -> { where.not(published_at: nil) }
  belongs_to :stream
  belongs_to :previous_stream, class_name: 'Stream', optional: true
  belongs_to :normalized_dump, dependent: :destroy

  delegate :marc21, :marcxml, :deletes, :oai_xml, :errata, :record_count, to: :normalized_dump
end
