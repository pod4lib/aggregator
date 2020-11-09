# frozen_string_literal: true

# Provide a pointer to a MARC record inside a file
class MarcRecord < ApplicationRecord
  belongs_to :file, class_name: 'ActiveStorage::Attachment'
  belongs_to :upload
  has_one :stream, through: :upload
  has_one :organization, through: :stream

  attr_accessor :marc_bytes
  attr_writer :marc

  # @return [MARC::Record]
  def marc
    return @marc if @marc

    @marc ||= if raw_marc
                read_single_marc_record
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
    return @marc_bytes if @marc_bytes

    return unless bytecount

    file.blob.service.download_chunk file.blob.key, bytecount...(bytecount + length)
  end

  def read_single_marc_record
    records = MARC::Reader.new(StringIO.new(raw_marc), external_encoding: 'UTF-8').to_a

    if records.one?
      records.first
    else
      merge_records(*records)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def merge_records(first_record, *other_records)
    record = MARC::Record.new

    record.leader = first_record.leader
    record.instance_variable_get(:@fields).concat(first_record.instance_variable_get(:@fields))

    other_records.each do |r|
      record.instance_variable_get(:@fields).concat(r.instance_variable_get(:@fields).reject do |field|
        field.tag < '010' ||
        field.tag > '841' ||
        record.instance_variable_get(:@fields).include?(field)
      end)

      # holdings... don't even try
      record.instance_variable_get(:@fields).concat(r.fields(('841'..'889').to_a))

      # local fields..
      record.instance_variable_get(:@fields).concat(r.fields(('900'..'999').to_a))
    end

    record.instance_variable_get(:@fields).reindex
    record
  end
  # rubocop:enable Metrics/AbcSize
end
