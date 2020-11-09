# frozen_string_literal: true

# Provide a pointer to a MARC record inside a file
class MarcRecord < ApplicationRecord
  belongs_to :file, class_name: 'ActiveStorage::Attachment'
  belongs_to :upload
  has_one :stream, through: :upload
  has_one :organization, through: :stream

  attr_writer :marc

  # @return [MARC::Record]
  def marc
    return @marc if @marc

    @marc ||= if raw_marc
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

  def augmented_marc
    return marc if organization&.code.blank?

    @augmented_marc ||= begin
      duped_record = MARC::Record.new_from_hash(marc.to_hash)
      duped_record.append(MARC::DataField.new('900', nil, nil, ['b', organization.code]))

      duped_record
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
