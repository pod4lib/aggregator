# frozen_string_literal: true

module AllowedConsumers
  # Table data component for allowed consumers
  class AccessTableDataComponent < SummaryTableDataComponent
    def explanation_text
      unless @other_org.provider?
        return I18n.t('allowed_consumers.summary_table_data_component.explanation.not_a_provider', grantor_name: grantor_name)
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
      (@other_org.allowed_consumer_groups & @organization.groups).map(&:display_name).to_sentence
    end

    def can_harvest?
      @other_org.provider? &&
        (@other_org.authenticated_users? || @organization.all_allowed_to_consume_organizations.include?(@other_org))
    end

    def unrestricted_access?
      @other_org.authenticated_users?
    end

    def can_harvest_via_group_membership?
      @other_org.allowed_consumer_groups.intersect?(@organization.groups)
    end

    def access_granted_directly?
      @other_org.allowed_consumer_organizations.include?(@organization)
    end
  end
end
