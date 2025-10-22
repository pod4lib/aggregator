# frozen_string_literal: true

module AllowedConsumers
  # Table data component for allowed consumers
  class SummaryTableDataComponent < ViewComponent::Base
    def initialize(organization:, other_org:)
      super()
      @organization = organization
      @other_org = other_org
    end

    def explanation_text # rubocop:disable Metrics/AbcSize
      if unrestricted_access?
        I18n.t('allowed_consumers.summary_table_data_component.explanation.unrestricted_access', grantor_name: grantor_name)
      elsif can_harvest_via_group_membership? && access_granted_directly?
        I18n.t('allowed_consumers.summary_table_data_component.explanation.granted_to_org_and_group',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      elsif access_granted_directly?
        I18n.t('allowed_consumers.summary_table_data_component.explanation.granted_to_organization', grantee_name: grantee_name)
      elsif can_harvest_via_group_membership?
        I18n.t('allowed_consumers.summary_table_data_component.explanation.granted_through_groups',
               grantee_name: grantee_name,
               groups: group_memberships_text)
      else
        I18n.t('allowed_consumers.summary_table_data_component.explanation.no_access_granted', grantee_name: grantee_name)
      end
    end

    def icon
      tag.i(class: icon_class, aria: { hidden: true }) +
        tag.span(icon_text, class: 'visually-hidden')
    end

    private

    def icon_class
      if can_harvest?
        'bi bi-check-circle-fill text-success'
      else
        'bi bi-dash'
      end
    end

    def icon_text
      if can_harvest?
        I18n.t('allowed_consumers.summary_table_data_component.can_harvest')
      else
        I18n.t('allowed_consumers.summary_table_data_component.cannot_harvest')
      end
    end

    def grantee_name
      @other_org.name
    end

    def grantor_name
      @organization.name
    end

    def group_memberships_text
      (@organization.allowed_consumer_groups & @other_org.groups).map(&:display_name).to_sentence
    end

    def can_harvest?
      @organization.authenticated_users? || @other_org.all_allowed_to_consume_organizations.include?(@organization)
    end

    def unrestricted_access?
      @organization.authenticated_users?
    end

    def can_harvest_via_group_membership?
      @organization.allowed_consumer_groups.intersect?(@other_org.groups)
    end

    def access_granted_directly?
      @organization.allowed_consumer_organizations.include?(@other_org)
    end
  end
end
