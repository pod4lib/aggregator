# frozen_string_literal: true

module Downloaders
  # Table data component for downloader access
  class GrantorAccessTableDataComponent < ViewComponent::Base
    def initialize(organization:, other_org:)
      super()
      @organization = organization
      @other_org = other_org
    end

    def explanation_text # rubocop:disable Metrics/AbcSize
      if unrestricted_access?
        I18n.t('downloaders.grantor_access_table_data_component.explanation.unrestricted_access', grantor_name: grantor_name)
      elsif can_harvest_via_group_membership? && access_granted_directly?
        I18n.t('downloaders.grantor_access_table_data_component.explanation.granted_to_org_and_group',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      elsif access_granted_directly?
        I18n.t('downloaders.grantor_access_table_data_component.explanation.granted_to_organization', grantee_name: grantee_name)
      elsif can_harvest_via_group_membership?
        I18n.t('downloaders.grantor_access_table_data_component.explanation.granted_through_groups',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      else
        I18n.t('downloaders.grantor_access_table_data_component.explanation.no_access_granted', grantee_name: grantee_name)
      end
    end

    def icon
      Downloaders::AccessStatusIconComponent.new(can_access: can_harvest?).call
    end

    private

    def grantee_name
      @other_org.name
    end

    def grantor_name
      @organization.name
    end

    def group_memberships_text
      (@organization.downloader_groups & @other_org.groups).map(&:display_name).to_sentence
    end

    def can_harvest?
      @organization.restrict_downloads == false || @other_org.effective_downloadable_organizations.include?(@organization)
    end

    def unrestricted_access?
      @organization.restrict_downloads == false
    end

    def can_harvest_via_group_membership?
      @organization.downloader_groups.intersect?(@other_org.groups)
    end

    def access_granted_directly?
      @organization.downloader_organizations.include?(@other_org)
    end
  end
end
