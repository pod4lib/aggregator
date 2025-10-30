# frozen_string_literal: true

##
# An extension that will be included into the ActiveStorage::Attachment class
module ActiveStorageAttachmentMetadataStatus
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
  def pod_metadata_status
    return :deletes if metadata['type'] == 'deletes'
    return :invalid if marc_analyzer? && metadata['valid'] == false
    return :not_marc if metadata['identified'] && metadata['analyzed'] && !marc_analyzer?
    return :success if metadata['analyzed'] && marc_analyzer?

    :unknown
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity

  def pod_error_message
    return 'Unacceptable data format' if pod_metadata_status == :not_marc

    metadata['error']
  end

  def pod_unknown_format?
    pod_metadata_status == :unknown
  end

  def pod_ok_format?
    pod_metadata_status&.in? %i[success deletes]
  end

  private

  def marc_analyzer?
    metadata['analyzer'] == 'MarcAnalyzer'
  end
end
