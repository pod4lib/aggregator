# frozen_string_literal: true

# Service to create an upload and kick off jobs to process it
class UploadCreatorService
  def initialize(upload)
    @upload = upload
  end

  def self.call(upload)
    new(upload).call
  end

  def call
    if @upload.save
      attach_remote_file_to_upload
      extract_files
      extract_marc_record_metadata
    end

    @upload
  end

  def extract_marc_record_metadata
    return unless @upload.active?

    ExtractMarcRecordMetadataJob.perform_later(@upload)
  end

  def extract_files
    return unless @upload.active?

    ExtractFilesJob.perform_later(@upload)
  end

  def attach_remote_file_to_upload
    return if @upload.url.blank?

    AttachRemoteFileToUploadJob.perform_later(@upload)
  end
end
