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

    # I guess we map upload statuses to job statuses to get round icons instead of file-like icons
    def status_icon(upload_status,
                    success_classes: 'bi bi-check-circle-fill align-middle text-success',
                    failure_classes: 'bi bi-x-circle-fill align-middle text-danger',
                    unknown_classes: 'bi bi-arrow-repeat align-middle text-info')
      case upload_status
      when 'needs_attention', 'invalid'
        tag.i class: failure_classes, role: 'img', aria: { label: 'Failed' }
      when 'success'
        tag.i class: success_classes, role: 'img', aria: { label: 'Completed' }
      else
        tag.i class: unknown_classes, role: 'img', aria: { label: 'Unknown' }
      end
    end

    # Return the most successful status level given a set up uploads
    def best_status(uploads)
      statuses = uploads.map(&:metadata_status)

      if statuses.include?('success')
        'success'
      elsif statuses.include?('needs_attention')
        'needs_attention'
      else
        'failed'
      end
    end
  end
end
