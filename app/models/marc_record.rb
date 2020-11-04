# frozen_string_literal: true

# Provide a pointer to a MARC record inside a file
class MarcRecord < ApplicationRecord
  belongs_to :file, class_name: 'ActiveStorage::Attachment'
  belongs_to :upload
  has_one :stream, through: :upload
  has_one :organization, through: :stream

  # @return [MARC::Record]
  def marc
    if raw_marc
      MARC::Reader.decode(raw_marc, external_encoding: 'UTF-8')
    elsif index
      file.blob.open do |tmpfile|
        marc_reader = MARC::XMLReader.new(tmpfile, parser: 'nokogiri')
        marc_reader.each.with_index do |record, index|
          return record if index == self.index
        end
      end
    end
  end

  private

  # Get the raw bytes for a MARC21 record
  # @return [String]
  def raw_marc
    return unless bytecount

    file.blob.service.download_chunk file.blob.key, bytecount...(bytecount + length)
  end
end