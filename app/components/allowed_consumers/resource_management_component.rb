# frozen_string_literal: true

module AllowedConsumers
  # Component for managing access
  class ResourceManagementComponent < ViewComponent::Base
    def initialize(organization:, resources:, resource_type: 'Group')
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
      tag.h5 I18n.t("allowed_consumers.resource_management_component.#{resource_type.downcase}.heading")
    end

    def description
      tag.p I18n.t("allowed_consumers.resource_management_component.#{resource_type.downcase}.description_html",
                   org_name: @organization.name), safe: true
    end

    def resource_link(resource)
      tag.a resource.display_name, href: helpers.group_path(resource)
    end

    def access_granted?(resource)
      @organization.allowed_consumer_groups.include?(resource)
    end

    def remove_consumer_link(resource)
      tag.a '',
            href: helpers.organization_remove_allowed_consumer_path(@organization,
                                                                    consumer_type: resource_type,
                                                                    consumer_id: resource.id),
            data: { turbo_method: :delete,
                    turbo_confirm: I18n.t('allowed_consumers.resource_management_component.confirm_remove',
                                          consumer: resource_name(resource), provider: @organization.name) },
            class: 'form-check-input checked',
            title: I18n.t('allowed_consumers.resource_management_component.remove_access')
    end

    def add_consumer_link(resource)
      tag.a '',
            href: helpers.organization_add_allowed_consumer_path(@organization, consumer_type: resource_type,
                                                                                consumer_id: resource.id),
            data: { turbo_method: :post,
                    turbo_confirm: I18n.t('allowed_consumers.resource_management_component.confirm_add',
                                          consumer: resource_name(resource), provider: @organization.name) },
            class: 'form-check-input',
            title: I18n.t('allowed_consumers.resource_management_component.add_access')
    end

    def resource_name(resource)
      resource.respond_to?(:display_name) ? resource.display_name : resource.name
    end
  end
end
