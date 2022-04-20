# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  default_scope { order(name: :asc) }
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy
  has_many :default_stream_histories, dependent: :destroy
  has_many :uploads, through: :streams
  has_many :marc_records, through: :streams, inverse_of: :organization
  has_many :allowlisted_jwts, as: :resource, dependent: :delete_all
  has_one :contact_email, dependent: :delete
  has_one_attached :icon
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

  def normalization_steps
    super || {}
  end

  def augmented_marc_record_service
    @augmented_marc_record_service ||= AugmentMarcRecordService.new(organization: self)
  end
end
