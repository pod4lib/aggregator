# frozen_string_literal: true

module Dashboard
  # Uploads tab showing recent uploads by provider
  class UploadsTabComponent < ViewComponent::Base
    attr_reader :uploads

    delegate :local_time, :datetime_display_format, to: :helpers

    def recent_uploads_by_provider
      @recent_uploads_by_provider ||= Organization.providers.index_with do |org|
        org.uploads.recent.where('uploads.created_at > ?', 30.days.ago)
      end
    end

    def most_recent_upload_status(uploads)
      uploads[0].metadata_status
    end

    # These are distinct from StatusIconComponents
    # They simply reflect a boolean success/failure state for the purpose of this tab's UI
    def success_icon_class(uploads)
      if best_status(uploads) == 'success'
        'bi bi-check-circle-fill align-middle text-success'
      else
        'bi bi-x-circle-fill align-middle text-danger'
      end
    end

    private

    # Return the most successful status level given a set up uploads
    def best_status(uploads)
      statuses ||= uploads.map(&:metadata_status).uniq.compact

      if statuses.include?('success')
        'success'
      elsif statuses.include?('needs_attention')
        'needs_attention'
      else
        'unknown'
      end
    end
  end
end
