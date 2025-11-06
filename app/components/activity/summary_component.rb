# frozen_string_literal: true

module Activity
  # Summary dashboard component showing recent uploads
  class SummaryComponent < ViewComponent::Base
    delegate :can?, to: :helpers
  end
end
