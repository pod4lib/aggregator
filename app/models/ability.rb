# frozen_string_literal: true

# Ability class that defines user-based abilities
class Ability
  include CanCan::Ability

  attr_reader :allowlisted_jwt, :user

  def initialize(user)
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
    can :read, Organization
    can :read, :dashboard
  end

  def user_with_roles_abilities
    return if user.roles.empty?

    can :read, ActiveStorage::Attachment
    can :read, MarcRecord
    can :read, Stream
    can :read, Upload
    can :read, :pages_data
  end

  def site_admin_user_abilities
    return unless user.has_role?(:admin) || user.has_role?(:superadmin)

    can :become, :superadmin

    return unless user.acting_as_superadmin?

    can :manage, :all
  end

  def organization_owner_abilities
    return if owned_organization_ids.empty?

    can :manage, Organization, id: owned_organization_ids
    can %i[create edit destroy], Stream, organization: { id: owned_organization_ids }
    can %i[create edit destroy], Upload, organization: { id: owned_organization_ids }
    can :manage, AllowlistedJwt, resource_type: 'Organization', resource_id: owned_organization_ids
  end

  def owned_organization_ids
    @owned_organization_ids ||= Organization.with_role(:owner, user).pluck(:id)
  end

  def organization_member_abilities
    return if member_organization_ids.empty?

    can %i[create], [Upload], organization: { id: member_organization_ids }
    can :read, AllowlistedJwt, resource_type: 'Organization', resource_id: member_organization_ids
  end

  def member_organization_ids
    @member_organization_ids ||= Organization.with_role(:member, user).pluck(:id)
  end

  def final_ability_restrictions
    cannot :destroy, Organization unless user.has_role?(:admin) || user.has_role?(:superadmin)
    cannot :destroy, Stream, status: %w[previous-default] unless user.has_role?(:admin) || user.has_role?(:superadmin)
    cannot :destroy, Stream, status: %w[default]
  end
end
