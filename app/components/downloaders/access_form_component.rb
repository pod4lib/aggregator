# frozen_string_literal: true

module Downloaders
  # Component for rendering a table to manage download access for organizations and groups
  class AccessFormComponent < ViewComponent::Base
    def initialize(organization:, resources:, resource_type:)
      super()
      @organization = organization
      @resources = resources
      @resource_type = resource_type
    end

    attr_reader :resource_type

    def render?
      @resources.any?
    end

    def heading
      tag.h5 I18n.t("downloaders.access_form_component.#{resource_type.downcase}.heading")
    end

    def description
      tag.p I18n.t("downloaders.access_form_component.#{resource_type.downcase}.description_html",
                   org_name: @organization.name), safe: true
    end
  end
end
