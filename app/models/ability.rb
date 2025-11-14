# frozen_string_literal: true

# Ability class that defines user-based abilities
class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user

    public_abilities

    return if user.blank?

    all_user_abilities
    user_with_roles_abilities
    site_admin_user_abilities
    organization_owner_abilities
    organization_member_abilities
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

    can :read, :pages_data

    # record/download access for unrestricted organizations
    can :read, ActiveStorage::Attachment, { record: { organization: { restrict_downloads: false } } }
    can :read, MarcRecord, upload: { organization: { restrict_downloads: false } }
    can :read, Stream, organization: { restrict_downloads: false }
    can :read, Upload, organization: { restrict_downloads: false }

    # record/download access for restricted organizations where access has been granted
    can :read, ActiveStorage::Attachment, { record: { organization: { id: permitted_organization_ids } } }
    can :read, MarcRecord, upload: { organization: { id: permitted_organization_ids } }
    can :read, Stream, organization: { id: permitted_organization_ids }
    can :read, Upload, organization: { id: permitted_organization_ids }
  end

  def permitted_organization_ids
    @permitted_organization_ids ||= user.organizations.flat_map(&:effective_downloadable_organizations).pluck(:id).uniq
  end

  def site_admin_user_abilities
    return unless user.has_role?(:admin) || user.has_role?(:superadmin)

    can :become, :superadmin

    return unless user.acting_as_superadmin?

    can :manage, :all
    cannot :destroy, Stream, status: %w[default]
  end

  def organization_owner_abilities
    return if owned_organization_ids.empty?

    can %i[edit administer invite], Organization, id: owned_organization_ids
    can %i[create update], Stream, organization: { id: owned_organization_ids }
    can :destroy, Stream, organization: { id: owned_organization_ids }, status: Stream::STATUSES - %w[default previous-default]
    can %i[create update destroy], Upload, organization: { id: owned_organization_ids }
    can :manage, AllowlistedJwt, resource_type: 'Organization', resource_id: owned_organization_ids
  end

  def owned_organization_ids
    @owned_organization_ids ||= Organization.with_role(:owner, user).pluck(:id)
  end

  def organization_member_abilities
    return if member_organization_ids.empty?

    can %i[create], [Upload], organization: { id: member_organization_ids }
    can :read, AllowlistedJwt, resource_type: 'Organization', resource_id: member_organization_ids
    # record/download access for organizations where the user is a member
    can :read, ActiveStorage::Attachment, { record: { organization: { id: member_organization_ids } } }
    can :read, MarcRecord, upload: { organization: { id: member_organization_ids } }
    can :read, Stream, organization: { id: member_organization_ids }
    can :read, Upload, organization: { id: member_organization_ids }
  end

  def member_organization_ids
    @member_organization_ids ||= Organization.with_role(:member, user).pluck(:id)
  end
end
