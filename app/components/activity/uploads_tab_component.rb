# frozen_string_literal: true

module Activity
  # Uploads tab showing recent uploads by provider
  class UploadsTabComponent < ViewComponent::Base
    attr_reader :uploads

    delegate :local_time, :datetime_display_format, to: :helpers

    def recent_uploads_by_provider
      @recent_uploads_by_provider ||= Organization.providers.index_with do |org|
        org.uploads.recent.where(created_at: 30.days.ago..)
      end
    end
  end
end
