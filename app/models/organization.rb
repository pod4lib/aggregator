# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy
  has_many :allowlisted_jwts, as: :resource, dependent: :delete_all

  def default_stream
    @default_stream ||= streams.find_or_create_by(default: true)
  end

  def jwt_token
    @jwt_token ||= begin
      jwt = allowlisted_jwts.first_or_create do |allow_listed|
        jti = Digest::MD5.hexdigest([id, Time.zone.now.to_i].join(':'))
        allow_listed.jti = jti
      end

      JWT.encode({ jti: jwt.jti }, Settings.jwt.secret, Settings.jwt.algorithm)
    end
  end
end
