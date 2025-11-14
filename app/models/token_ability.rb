# frozen_string_literal: true

# Ability class that defines token-based abilities
class TokenAbility
  include CanCan::Ability

  attr_reader :allowlisted_jwt

  def initialize(token)
    @token = token
    @allowlisted_jwt = AllowlistedJwt.find_by(jti: token_jti)

    return unless token

    any_token_abilities
    scoped_token_abilities
  end

  private

  def any_token_abilities
    can :read, Organization, allowlisted_jwts: { jti: token_jti }
  end

  # Scoped token abilities:
  # - 'all' scope: upload and download abilities
  # - 'upload' scope: upload abilities only
  # - 'download' scope: download abilities only
  def scoped_token_abilities
    case allowlisted_jwt.scope
    when 'all'
      token_upload_abilities
      token_download_abilities
    when 'upload'
      token_upload_abilities
    when 'download'
      token_download_abilities
    end

    allowlisted_jwt&.update(updated_at: Time.zone.now)
  end

  def token_upload_abilities
    can %i[create update], [Stream, Upload], organization: { allowlisted_jwts: { jti: token_jti } }
  end

  def token_download_abilities
    can :read, Organization

    # record/download access for unrestricted organizations
    can :read, [Stream, Upload], organization: { restrict_downloads: false }
    can :read, ActiveStorage::Attachment, { record: { organization: { restrict_downloads: false } } }

    # record/download access for organization linked to the token
    can :read, [Stream, Upload], organization: { allowlisted_jwts: { jti: token_jti } }
    can :read, ActiveStorage::Attachment, { record: { organization: { allowlisted_jwts: { jti: token_jti } } } }

    # record/download access for restricted organizations where access has been granted
    can :read, [Stream, Upload], organization: { id: permitted_organization_ids }
    can :read, ActiveStorage::Attachment, { record: { organization: { id: permitted_organization_ids } } }
  end

  def permitted_organization_ids
    @permitted_organization_ids ||= @allowlisted_jwt&.resource&.effective_downloadable_organizations&.pluck(:id)
  end

  def token_jti
    @token['jti'] if @token
  end
end
