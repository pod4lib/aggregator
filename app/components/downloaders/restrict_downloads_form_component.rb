# frozen_string_literal: true

module Downloaders
  # Component for rendering a form that sets whether an organization's download access
  # is unrestricted or restricted to certain groups and organizations.
  class RestrictDownloadsFormComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def render?
      helpers.can?(:control_access, @organization)
    end
  end
end
