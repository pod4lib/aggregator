# frozen_string_literal: true

# nodoc
module DashboardHelper
  # Return the last successful upload given a set up uploads, otherwise nil
  def last_successful_upload_date(uploads)
    uploads.each do |upload|
      return upload.created_at if files_status(upload) == 'completed'
    end
  end

  # Return the most successful status level given a set up uploads
  # See https://github.com/pod4lib/aggregator/issues/674
  def best_status(uploads)
    statuses = []
    uploads.each do |upload|
      statuses |= [files_status(upload)]
    end
    return 'completed' if statuses.include? 'completed'
    return 'needs_attention' if statuses.include? 'needs_attention'
    return 'failed' if statuses.include? 'failed'
  end

  # Status criteria outlined in https://github.com/pod4lib/aggregator/issues/674
  # Completed - When all files in the upload are flagged as valid MARC or deletes
  # Needs attention - Some, but not all files in upload are flagged as invalid MARC or Neither MARC nor deletes
  # Failed - All files in upload are flagged as invalid MARC or Neither MARC nor deletes

  # rubocop:disable Metrics/PerceivedComplexity
  def files_status(upload)
    statuses = upload.files.map(&:pod_metadata_status).uniq

    if statuses.include?(:deletes) || statuses.include?(:success)
      if statuses.include?(:invalid) || statuses.include?(:not_marc) || statuses.include?(:unknown)
        'needs_attention'
      else
        'completed'
      end
    else
      'failed'
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
end
