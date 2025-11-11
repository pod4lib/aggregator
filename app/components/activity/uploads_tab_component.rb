# frozen_string_literal: true

module Activity
  # Uploads tab showing recent uploads by provider
  class UploadsTabComponent < ViewComponent::Base
    attr_reader :uploads

    delegate :local_time, :datetime_display_format, :current_ability, to: :helpers

    def recent_uploads_by_provider
      @recent_uploads_by_provider ||= Organization.accessible_by(current_ability).providers.index_with do |org|
        org.default_stream.uploads.recent.where(created_at: 30.days.ago..)
      end
    end
  end
end
