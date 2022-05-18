# frozen_string_literal: true

# nodoc
module DashboardHelper
  # Return the last successful upload given a set up uploads, otherwise nil
  def last_successful_upload_date(uploads)
    uploads.find { |upload| files_status(upload) == 'completed' }&.created_at
  end

  # Return the most successful status level given a set up uploads
  def best_status(uploads)
    statuses = uploads.map { |upload| files_status(upload) }.uniq

    return 'completed' if statuses.include? 'completed'
    return 'needs_attention' if statuses.include? 'needs_attention'
    return 'failed' if statuses.include? 'failed'
  end

  # Status criteria outlined in https://github.com/pod4lib/aggregator/issues/674
  # Completed - When all files in the upload are flagged as valid MARC or deletes
  # Needs attention - Some, but not all files in upload are flagged as invalid MARC or Neither MARC nor deletes
  # Failed - All files in upload are flagged as invalid MARC or Neither MARC nor deletes
  def files_status(upload)
    statuses = upload.files.map(&:pod_metadata_status).uniq

    if any_successes?(statuses) && any_failures?(statuses)
      'needs_attention'
    elsif any_successes?(statuses)
      'completed'
    else
      'failed'
    end
  end

  def any_successes?(statuses)
    (%i[deletes success] & statuses).any?
  end

  def any_failures?(statuses)
    (%i[invalid not_marc unknown] & statuses).any?
  end
end
