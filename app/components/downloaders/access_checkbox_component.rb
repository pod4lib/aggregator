# frozen_string_literal: true

module Downloaders
  # Component for rendering a checkbox to manage download access for a resource
  class AccessCheckboxComponent < ViewComponent::Base
    def initialize(organization:, resource:)
      super()
      @organization = organization
      @resource = resource
    end

    def access_display
      helpers.can?(:control_access, @organization) && @organization.restrict_downloads ? access_link : icon
    end

    private

    def icon
      StatusIcons::DownloadAccessIconComponent.new(status: icon_status).call
    end

    def icon_status
      !@organization.restrict_downloads || access_granted? ? 'can_access' : 'cannot_access'
    end

    def access_link
      if access_granted?
        revoke_download_access_link + checkbox_input
      else
        grant_download_access_link
      end
    end

    def access_granted?
      @organization.downloader_groups.include?(@resource) ||
        @organization.downloader_organizations.include?(@resource)
    end

    def checkbox_input
      tag.input type: 'checkbox', class: 'form-check-input pe-none', aria: { label: 'Access granted?' }, checked: 'checked'
    end

    def revoke_download_access_link
      downloader = @organization.downloaders.find_by(resource: @resource)
      tag.a '',
            href: helpers.organization_downloader_path(@organization, downloader),
            data: { turbo_method: :delete,
                    turbo_confirm: I18n.t('downloaders.access_form_component.confirm_remove',
                                          consumer: resource_name, provider: @organization.name) },
            class: 'form-check-input checked',
            title: I18n.t('downloaders.access_form_component.revoke_access')
    end

    def grant_download_access_link
      tag.a '',
            href: helpers.organization_downloaders_path(@organization, resource_type: @resource.class.name,
                                                                       resource_id: @resource.id),
            data: { turbo_method: :post,
                    turbo_confirm: I18n.t('downloaders.access_form_component.confirm_add',
                                          consumer: resource_name, provider: @organization.name) },
            class: 'form-check-input',
            title: I18n.t('downloaders.access_form_component.grant_access')
    end

    def resource_name
      @resource.respond_to?(:display_name) ? @resource.display_name : @resource.name
    end
  end
end
