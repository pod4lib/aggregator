# frozen_string_literal: true

# Provide a pointer to a MARC record inside a file
class MarcRecord < ApplicationRecord
  belongs_to :file, class_name: 'ActiveStorage::Attachment'
  belongs_to :upload
  has_one :stream, through: :upload, inverse_of: :marc_records
  has_one :organization, through: :stream, inverse_of: :marc_records

  attr_accessor :marc_bytes
  attr_writer :marc

  # @return [MARC::Record]
  def marc
    @marc ||= if json
                load_record_from_json
              elsif bytecount && length
                service.at_bytes(bytecount...(bytecount + length), merge: true)
              elsif index
                service.at_index(index)
              end
  end

  def augmented_marc
    return marc unless upload.organization

    @augmented_marc ||= upload.organization.augmented_marc_record_service.execute(marc)
  end

  private

  def service
    @service ||= MarcRecordService.new(file.blob)
  end

  def load_record_from_json
    MARC::Record.new_from_marchash(JSON.parse(Zlib::Inflate.inflate(json)))
  end
end
