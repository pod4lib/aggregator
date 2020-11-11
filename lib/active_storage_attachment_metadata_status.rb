# frozen_string_literal: true

##
# An extension that will be included into the ActiveStorage::Attachment class
module ActiveStorageAttachmentMetadataStatus
  # rubocop:disable Metrics/CyclomaticComplexity
  def pod_metadata_status
    return :invalid if marc_analyzer? && metadata['valid'] == false
    return :unknown if metadata['identified'] && metadata['analyzed'] && !marc_analyzer?
    return :success if metadata['analyzed'] && marc_analyzer?

    :unknown
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  def marc_analyzer?
    metadata['analyzer'] == 'MarcAnalyzer'
  end
end
