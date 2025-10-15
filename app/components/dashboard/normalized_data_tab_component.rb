# frozen_string_literal: true

module Dashboard
  # Normalized data tab showing latest normalized dumps by provider
  class NormalizedDataTabComponent < ViewComponent::Base
    delegate :local_time, :datetime_display_format, to: :helpers

    def normalized_data_by_provider
      @normalized_data_by_provider ||= Organization.providers.index_with do |org|
        org.default_stream.normalized_dumps.full_dumps.published.last
      end
    end
  end
end
