# frozen_string_literal: true

module Dashboard
  # Uploads tab showing recent uploads by provider
  class UploadsTabComponent < ViewComponent::Base
    attr_reader :uploads

    delegate :local_time, :datetime_display_format, to: :helpers

    def recent_uploads_by_provider
      @recent_uploads_by_provider ||= Organization.providers.index_with do |org|
        org.uploads.recent.where(created_at: 30.days.ago..)
      end
    end

    def provider_status_icon(uploads) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      any_successes = uploads.any? { |u| u.metadata_status == 'success' }

      if any_successes && uploads.all? { |u| u.metadata_status == 'success' }
        ok_icon
      elsif any_successes && uploads.any? { |u| u.metadata_status&.in?(%w[invalid needs_attention unknown]) }
        warning_icon
      else
        no_data_icon
      end
    end

    private

    def ok_icon
      tag.i(title: 'OK', role: 'img', aria: { label: 'OK' }, class: 'bi bi-check-circle-fill text-success')
    end

    def warning_icon
      tag.i(title: 'Warning', role: 'img',  aria: { label: 'Warning' }, class: 'bi bi-exclamation-triangle-fill text-warning')
    end

    def no_data_icon
      tag.i(title: 'No data', role: 'img',  aria: { label: 'No recent data' }, class: 'bi bi-x-circle-fill text-danger')
    end
  end
end
