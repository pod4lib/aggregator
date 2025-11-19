# frozen_string_literal: true

module Downloaders
  # Component for rendering controls related to administering download access
  # for organizations and groups
  class AdministerAccessComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def groups
      @groups ||= Group.accessible_by(helpers.current_ability)
    end

    def other_organizations
      @other_organizations ||= Organization.accessible_by(helpers.current_ability).where.not(id: @organization.id)
    end
  end
end
