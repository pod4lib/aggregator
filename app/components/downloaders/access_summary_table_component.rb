# frozen_string_literal: true

module Downloaders
  # Component for rendering a table that summarizes download access for an organization.
  class AccessSummaryTableComponent < ViewComponent::Base
    def initialize(organization:, other_organizations:)
      super()
      @organization = organization
      @other_organizations = other_organizations
    end
  end
end
