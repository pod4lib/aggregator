# frozen_string_literal: true

module Dashboard
  # Uploads tab showing recent uploads by provider
  class UploadsTabComponent < ViewComponent::Base
    attr_reader :uploads

    delegate :local_time, :datetime_display_format, to: :helpers

    def initialize(uploads:)
      @uploads = uploads
      super()
    end

    def recent_uploads_by_provider
      @recent_uploads_by_provider ||= Organization.providers.index_with do |org|
        org.uploads.recent.where('uploads.created_at > ?', 30.days.ago)
      end
    end

    def last_successful_upload_date
      @last_successful_upload_date ||=
        @uploads.find { |upload| files_status(upload) == :completed }&.created_at
    end

    def status
      @status ||= best_status
    end

    private

    # Return the most successful status level given a set up uploads
    def best_status
      statuses = @uploads.map { |upload| files_status(upload) }.uniq

      return :completed if statuses.include? :completed
      return :needs_attention if statuses.include? :needs_attention

      :failed if statuses.include? :failed
    end

    # Status criteria outlined in https://github.com/pod4lib/aggregator/issues/674
    # Completed - When all files in the upload are flagged as valid MARC or deletes
    # Needs attention - Some, but not all files in upload are flagged as invalid MARC or Neither MARC nor deletes
    # Failed - All files in upload are flagged as invalid MARC or Neither MARC nor deletes
    def files_status(upload)
      statuses = upload.files.map(&:pod_metadata_status).uniq

      if any_successes?(statuses) && any_failures?(statuses)
        :needs_attention
      elsif any_successes?(statuses)
        :completed
      elsif upload.active?
        :active
      else
        :failed
      end
    end

    def any_successes?(statuses)
      %i[deletes success].intersect?(statuses)
    end

    def any_failures?(statuses)
      %i[invalid not_marc].intersect?(statuses)
    end
  end
end
