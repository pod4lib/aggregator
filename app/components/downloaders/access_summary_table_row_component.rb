# frozen_string_literal: true

module Downloaders
  # Component for rendering a table row that summarizes download access for an organization.
  class AccessSummaryTableRowComponent < ViewComponent::Base
    def initialize(organization:, other_org:)
      super()
      @organization = organization
      @other_org = other_org
    end
  end
end
