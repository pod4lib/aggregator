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
      @resources.any? && helpers.can?(:control_access, @organization)
    end

    def heading
      tag.h5 I18n.t("downloaders.access_form_component.#{resource_type.downcase}.heading")
    end

    def description
      tag.p I18n.t("downloaders.access_form_component.#{resource_type.downcase}.description_html",
                   org_name: @organization.name), safe: true
    end

    def access_granted?(resource)
      @organization.downloader_groups.include?(resource) ||
        @organization.downloader_organizations.include?(resource)
    end

    def revoke_download_access_link(resource)
      downloader = @organization.downloaders.find_by(resource: resource)
      tag.a '',
            href: helpers.organization_downloader_path(@organization, downloader),
            data: { turbo_method: :delete,
                    turbo_confirm: I18n.t('downloaders.access_form_component.confirm_remove',
                                          consumer: resource_name(resource), provider: @organization.name) },
            class: 'form-check-input checked',
            title: I18n.t('downloaders.access_form_component.revoke_access')
    end

    def grant_download_access_link(resource)
      tag.a '',
            href: helpers.organization_downloaders_path(@organization, resource_type: resource_type, resource_id: resource.id),
            data: { turbo_method: :post,
                    turbo_confirm: I18n.t('downloaders.access_form_component.confirm_add',
                                          consumer: resource_name(resource), provider: @organization.name) },
            class: 'form-check-input',
            title: I18n.t('downloaders.access_form_component.grant_access')
    end

    def resource_name(resource)
      resource.respond_to?(:display_name) ? resource.display_name : resource.name
    end
  end
end
