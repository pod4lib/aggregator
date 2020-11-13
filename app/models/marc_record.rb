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
  # rubocop:disable Metrics/AbcSize
  def marc
    @marc ||= if marc_bytes
                merge_records(*service.from_bytes(marc_bytes).to_a)
              elsif bytecount && length
                merge_records(*service.at_bytes(bytecount...(bytecount + length)).to_a)
              elsif index
                service.at_index(index)
              end
  end
  # rubocop:enable Metrics/AbcSize

  def augmented_marc
    return marc unless organization

    @augmented_marc ||= organization.augmented_marc_record_service.execute(marc)
  end

  private

  def service
    @service ||= MarcRecordService.new(file.blob)
  end

  # rubocop:disable Metrics/AbcSize
  def merge_records(first_record, *other_records)
    return first_record if other_records.blank?

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
