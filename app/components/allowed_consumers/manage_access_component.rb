# frozen_string_literal: true

module AllowedConsumers
  # Component for managing access
  class ManageAccessComponent < ViewComponent::Base
    def initialize(organization:, groups:, other_organizations:)
      super()
      @organization = organization
      @groups = groups
      @other_organizations = other_organizations
    end

    def render?
      @organization.managed? && helpers.can?(:manage, @organization)
    end
  end
end
