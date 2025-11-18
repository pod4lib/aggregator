# frozen_string_literal: true

module Downloaders
  # Component for rendering controls related to administering download access
  # for organizations and groups
  class AdministerAccessComponent < ViewComponent::Base
    def initialize(organization:, groups:, other_organizations:)
      super()
      @organization = organization
      @groups = groups
      @other_organizations = other_organizations
    end

    def render?
      helpers.can?(:control_access, @organization)
    end
  end
end
