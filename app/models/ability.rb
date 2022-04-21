# frozen_string_literal: true

# :nodoc:
class Ability
  include CanCan::Ability
  attr_reader :allowlisted_jwt, :user

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def initialize(user, token = nil)
    alias_action :create, :read, :update, :destroy, to: :crud

    can :confirm, ContactEmail
    return unless user || token

    @user = user

    if token
      can :read, Organization, allowlisted_jwts: { jti: token['jti'] }

      @allowlisted_jwt = AllowlistedJwt.find_by(jti: token['jti'])

      case @allowlisted_jwt.scope
      when 'all'
        can %i[create update], [Stream, Upload], organization: { allowlisted_jwts: { jti: token['jti'] } }
        can :read, Organization, public: true
        can :read, [Stream, Upload], organization: { public: true }

        can :read, ActiveStorage::Attachment, { record: { organization: { public: true } } }
      when 'upload'
        can %i[create update], [Stream, Upload], organization: { allowlisted_jwts: { jti: token['jti'] } }
      when 'download'
        can :read, Organization, public: true
        can :read, [Stream, Upload], organization: { public: true }

        can :read, ActiveStorage::Attachment, { record: { organization: { public: true } } }
      end

      allowlisted_jwt&.update(updated_at: Time.zone.now)
      return
    end

    if user.roles.any?
      can :read, ActiveStorage::Attachment, { record: { organization: { public: true } } }
      can :read, MarcRecord, upload: { organization: { public: true } }
      can %i[read profile info], [Stream, Upload], organization: { public: true }
      can :read, :pages_data
      can %i[read users organization_details provider_details normalized_data processing_status], Organization, public: true
    end

    can :manage, :all if user.has_role?(:admin)
    cannot :delete, Stream, default: true
    can :read, Organization, public: true
    can :manage, :dashboard_controller if user.has_role?(:admin)
    can :manage, :organization_slug if user.has_role?(:admin)

    owned_orgs = Organization.with_role(:owner, user).pluck(:id)
    can :manage, Organization, id: owned_orgs
    can %i[crud profile info], [Stream, Upload], organization: { id: owned_orgs }
    can :read, MarcRecord, upload: { organization: { id: owned_orgs } }
    can :manage, AllowlistedJwt, resource_type: 'Organization', resource_id: owned_orgs
    can :manage, :allowlisted_jwts_controller, resource_type: 'Organization', resource_id: owned_orgs
    can :read, ActiveStorage::Attachment, { record: { organization: { id: owned_orgs } } }

    member_orgs = Organization.with_role(:member, user).pluck(:id)
    can %i[invite], Organization, id: member_orgs
    can %i[read profile info], [Stream, Upload], organization: { id: member_orgs }
    can %i[create], [Upload], organization: { id: member_orgs }
    can :read, MarcRecord, upload: { organization: { id: member_orgs } }
    #can :read, AllowlistedJwt, resource_type: 'Organization', resource_id: member_orgs
    can :read, ActiveStorage::Attachment, { record: { organization: { id: member_orgs } } }
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
