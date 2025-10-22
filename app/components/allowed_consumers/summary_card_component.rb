# frozen_string_literal: true

module AllowedConsumers
  # Summary card component for allowed consumers
  class SummaryCardComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def card_text # rubocop:disable Metrics/AbcSize
      if @organization.authenticated_users?
        t('allowed_consumers.summary_card_component.unrestricted_access', org_name: @organization.name)
      elsif @organization.allowed_consumer_groups.any? && @organization.allowed_consumer_organizations.any?
        t('allowed_consumers.summary_card_component.restricted_group_and_org_access', org_name: @organization.name)
      elsif @organization.allowed_consumer_groups.any?
        t('allowed_consumers.summary_card_component.restricted_group_access', org_name: @organization.name)
      elsif @organization.allowed_consumer_organizations.any?
        t('allowed_consumers.summary_card_component.restricted_org_access', org_name: @organization.name)
      else
        t('allowed_consumers.summary_card_component.no_access', org_name: @organization.name)
      end
    end
  end
end
