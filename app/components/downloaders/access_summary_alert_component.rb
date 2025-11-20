# frozen_string_literal: true

module Downloaders
  # Component that renders an alert summarizing the current download restrictions for an organization.
  class AccessSummaryAlertComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def alert_text # rubocop:disable Metrics/AbcSize
      if !@organization.restrict_downloads?
        t('downloaders.access_summary_alert_component.unrestricted_access', org_name: @organization.name)
      elsif @organization.downloader_groups.any? && @organization.downloader_organizations.any?
        t('downloaders.access_summary_alert_component.restricted_group_and_org_access', org_name: @organization.name)
      elsif @organization.downloader_groups.any?
        t('downloaders.access_summary_alert_component.restricted_group_access', org_name: @organization.name)
      elsif @organization.downloader_organizations.any?
        t('downloaders.access_summary_alert_component.restricted_org_access', org_name: @organization.name)
      else
        t('downloaders.access_summary_alert_component.no_access', org_name: @organization.name)
      end
    end
  end
end
