# frozen_string_literal: true

module Downloaders
  # Component for rendering a table that summarizes download access for an organization.
  class AccessSummaryTableComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def other_organizations
      @other_organizations ||= Organization.accessible_by(helpers.current_ability).where.not(id: @organization.id)
    end
  end
end
