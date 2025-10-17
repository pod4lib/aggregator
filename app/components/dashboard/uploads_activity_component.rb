# frozen_string_literal: true

module Dashboard
  # Uploads activity table showing recent uploads by provider
  class UploadsActivityComponent < ViewComponent::Base
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
  end
end
