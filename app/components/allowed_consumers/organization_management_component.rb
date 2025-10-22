# frozen_string_literal: true

module AllowedConsumers
  # Component for managing access
  class OrganizationManagementComponent < ResourceManagementComponent
    def resource_link(resource)
      tag.a resource.name, href: helpers.organization_path(resource)
    end

    def access_granted?(resource)
      @organization.allowed_consumer_organizations.include?(resource)
    end
  end
end
