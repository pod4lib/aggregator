# frozen_string_literal: true

module Downloaders
  # Table data component for downloader access
  class AccessSummaryTableDataComponent < ViewComponent::Base
    def initialize(grantor_org:, grantee_org:)
      super()
      @grantor_org = grantor_org
      @grantee_org = grantee_org
    end

    def explanation_text # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      if !@grantor_org.provider?
        I18n.t('downloaders.access_summary_table_data_component.explanation.not_a_provider',
               grantor_name: grantor_name)
      elsif unrestricted_access?
        I18n.t('downloaders.access_summary_table_data_component.explanation.unrestricted_access', grantor_name: grantor_name)
      elsif access_granted_via_group_membership? && access_granted_directly?
        I18n.t('downloaders.access_summary_table_data_component.explanation.granted_to_org_and_group',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      elsif access_granted_directly?
        I18n.t('downloaders.access_summary_table_data_component.explanation.granted_to_organization', grantee_name: grantee_name)
      elsif access_granted_via_group_membership?
        I18n.t('downloaders.access_summary_table_data_component.explanation.granted_through_groups',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      else
        I18n.t('downloaders.access_summary_table_data_component.explanation.no_access_granted', grantee_name: grantee_name)
      end
    end

    def icon
      StatusIcons::DownloadAccessIconComponent.new(status: can_download? ? 'can_access' : 'cannot_access').call
    end

    private

    def grantee_name
      @grantee_org.name
    end

    def grantor_name
      @grantor_org.name
    end

    def group_memberships_text
      (@grantor_org.downloader_groups & @grantee_org.groups).map(&:display_name).to_sentence
    end

    def can_download?
      unrestricted_access? || @grantee_org.effective_downloadable_organizations.include?(@grantor_org)
    end

    def unrestricted_access?
      !@grantor_org.restrict_downloads?
    end

    def access_granted_via_group_membership?
      @grantor_org.downloader_groups.intersect?(@grantee_org.groups)
    end

    def access_granted_directly?
      @grantor_org.downloader_organizations.include?(@grantee_org)
    end
  end
end
