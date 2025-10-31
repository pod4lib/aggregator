# frozen_string_literal: true

# Ability class that defines user-based abilities
class Ability
  include CanCan::Ability

  attr_reader :allowlisted_jwt, :user

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    @user = user

    public_abilities

    return if user.blank?

    all_user_abilities
    user_with_roles_abilities
    site_admin_user_abilities
    organization_owner_abilities
    organization_member_abilities
    final_ability_restrictions
  end

  private

  def public_abilities
    can :confirm, ContactEmail
  end

  def all_user_abilities
    can :read, Organization, public: true
  end

  def user_with_roles_abilities
    return if user.roles.empty?

    can :read, :pages_data
    can %i[read users organization_details provider_details], Organization, public: true
    can :read, [Organization, AllowedConsumer], { public: true }

    # Permits record access for organizations that permit all authenticated users
    record_read_abilities
    # Permits record access as allowed by organizations that have restrictions in place
    record_read_abilities({ id: permitted_organization_ids, public: true })
  end

  def record_read_abilities(restrictions = { record_access: :authenticated_users, public: true })
    can :read, ActiveStorage::Attachment, { record: { organization: restrictions } }
    can :read, MarcRecord, upload: { organization: restrictions }
    can %i[read profile normalized_data processing_status], Stream, organization: restrictions
    can %i[read info], Upload, organization: restrictions
  end

  def permitted_organization_ids
    @permitted_organization_ids ||= @user.organizations.flat_map(&:allowed_to_consume_organization_ids)
  end

  def site_admin_user_abilities
    return unless user.has_role?(:admin)

    can :manage, :all
    can :manage, :dashboard_controller
    can :manage, :organization_slug
  end

  def organization_owner_abilities
    return if owned_organization_ids.empty?

    can :manage, Organization, id: owned_organization_ids
    can :crud, Stream, organization: { id: owned_organization_ids }
    can :crud, Upload, organization: { id: owned_organization_ids }
    can :manage, AllowlistedJwt, resource_type: 'Organization', resource_id: owned_organization_ids
  end

  def owned_organization_ids
    @owned_organization_ids ||= Organization.with_role(:owner, user).pluck(:id)
  end

  def organization_member_abilities
    return if member_organization_ids.empty?

    can %i[invite], Organization, id: member_organization_ids
    can %i[create], [Upload], organization: { id: member_organization_ids }
    can :read, MarcRecord, upload: { organization: { id: member_organization_ids } }
    can :read, AllowlistedJwt, resource_type: 'Organization', resource_id: member_organization_ids
    can :read, ActiveStorage::Attachment, { record: { organization: { id: member_organization_ids } } }
  end

  def member_organization_ids
    @member_organization_ids ||= Organization.with_role(:member, user).pluck(:id)
  end

  def final_ability_restrictions
    cannot :destroy, Organization unless user.has_role?(:admin)
    cannot :destroy, Stream, status: %w[previous-default] unless user.has_role?(:admin)
    cannot :destroy, Stream, status: %w[default]
  end
end
