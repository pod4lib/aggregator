# frozen_string_literal: true

# Provide a pointer to a MARC record inside a file
class MarcRecord < ApplicationRecord
  belongs_to :file, class_name: 'ActiveStorage::Attachment'
  belongs_to :upload
  has_one :stream, through: :upload, inverse_of: :marc_records
  has_one :organization, through: :stream, inverse_of: :marc_records

  attr_accessor :marc_bytes

  before_create :copy_organization_from_upload

  # @return [MARC::Record]
  def marc
    @marc ||= load_record_from_json
  end

  def marc=(record)
    @marc = record
    self.marc001 = record['001']&.value

    self.json = Zlib::Deflate.new.deflate(record.to_marchash.to_json, Zlib::FINISH)
  end

  # See http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
  def oai_id
    "oai:#{Settings.oai_repository_id}:#{organization.slug}:#{stream.id}:#{marc001}"
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
    MARC::Record.new_from_marchash(JSON.parse(Zlib::Inflate.inflate(json))) if json
  end

  def copy_organization_from_upload
    self.organization_id = upload.organization.id
  end
end
