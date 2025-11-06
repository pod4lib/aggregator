# frozen_string_literal: true

module Activity
  # Normalized data tab showing latest normalized dumps by provider
  class NormalizedDataTabComponent < ViewComponent::Base
    delegate :local_time, :datetime_display_format, :current_ability, to: :helpers

    def normalized_data_by_provider
      @normalized_data_by_provider ||= Organization.accessible_by(current_ability).providers.index_with do |org|
        org.default_stream.full_dumps.published.last
      end
    end
  end
end
