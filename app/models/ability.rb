# frozen_string_literal: true

# :nodoc:
class Ability
  include CanCan::Ability
  attr_reader :allowlisted_jwt, :user

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def initialize(user, token = nil)
    can :confirm, ContactEmail
    return unless user || token

    @user = user
    if token
      token_payload = if token
                        JWT.decode(
                          token,
                          Settings.jwt.secret,
                          Settings.jwt.algorithm
                        )[0]
                      else
                        {}
                      end

      can :read, Organization, allowlisted_jwts: { jti: token_payload['jti'] }

      can %i[create read update], [Stream, Upload], organization: { allowlisted_jwts: { jti: token_payload['jti'] } }

      @allowlisted_jwt = AllowlistedJwt.find_by(jti: token_payload['jti'])
      allowlisted_jwt&.update(updated_at: Time.zone.now)
      return
    end

    can :manage, :all if user.has_role?(:admin)
    can :read, Organization if user

    owned_orgs = Organization.with_role(:owner, user).pluck(:id)
    can :manage, Organization, id: owned_orgs
    can :manage, [Stream, Upload], organization: { id: owned_orgs }

    member_orgs = Organization.with_role(:member, user).pluck(:id)
    can :invite, Organization, id: member_orgs
    can :manage, [Stream, Upload], organization: { id: member_orgs }
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
