# frozen_string_literal: true

module Downloaders
  # Table data component that shows which organizations this organization can access
  class AccessibleSummaryTableDataComponent < AccessSummaryTableDataComponent
    def explanation_text
      unless @other_org.provider?
        return I18n.t('downloaders.accessible_summary_table_data_component.explanation.not_a_provider',
                      grantor_name: grantor_name)
      end

      super
    end

    private

    def grantee_name
      @organization.name
    end

    def grantor_name
      @other_org.name
    end

    def group_memberships_text
      (@other_org.downloader_groups & @organization.groups).map(&:display_name).to_sentence
    end

    def can_download?
      @other_org.provider? &&
        (unrestricted_access? || @organization.effective_downloadable_organizations.include?(@other_org))
    end

    def unrestricted_access?
      !@other_org.restrict_downloads
    end

    def access_granted_via_group_membership?
      @other_org.downloader_groups.intersect?(@organization.groups)
    end

    def access_granted_directly?
      @other_org.downloader_organizations.include?(@organization)
    end
  end
end
