# frozen_string_literal: true

module AllowedConsumers
  # Component for rendering a summary table of allowed consumers
  class SummaryTableComponent < ViewComponent::Base
    def initialize(organization:, other_organizations:)
      super()
      @organization = organization
      @other_organizations = other_organizations
    end
  end
end
