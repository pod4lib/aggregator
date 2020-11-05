# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy
  has_many :marc_records, through: :streams
  has_many :allowlisted_jwts, as: :resource, dependent: :delete_all
  has_many :contact_emails, dependent: :delete_all
  has_one_attached :icon
  has_many_attached :full_dump_binary
  has_many_attached :full_dump_xml
  has_many :statistics, dependent: :delete_all, as: :resource

  def default_stream
    @default_stream ||= streams.find_or_create_by(default: true)
  end

  def jwt_token
    @jwt_token ||= allowlisted_jwts.first_or_create.encoded_token
  end

  def latest_statistics
    statistics.latest.first_or_initialize
  end
end
