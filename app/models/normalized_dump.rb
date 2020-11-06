# frozen_string_literal: true

# :nodoc:
class NormalizedDump < ApplicationRecord
  belongs_to :stream
  has_one :organization, through: :stream

  has_one_attached :full_dump_binary
  has_one_attached :full_dump_xml
  has_many_attached :delta_dump_binary
  has_many_attached :delta_dump_xml
end
