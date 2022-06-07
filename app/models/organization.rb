# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  default_scope { order(name: :asc) }
  resourcify
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy
  has_many :default_stream_histories, through: :streams, inverse_of: :organization
  has_many :uploads, through: :streams
  has_many :marc_records, through: :streams, inverse_of: :organization
  has_many :allowlisted_jwts, as: :resource, dependent: :delete_all
  has_one :contact_email, dependent: :delete
  has_one_attached :icon
  has_many :statistics, dependent: :delete_all, as: :resource
  accepts_nested_attributes_for :contact_email, update_only: true, reject_if: proc { |att| att['email'].blank? }
  has_many :users, -> { distinct }, through: :roles, class_name: 'User', source: :users
  scope :providers, -> { where(provider: true) }
  validates :marc_docs_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

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

  def slug=(slug)
    super(slug.presence)
  end

  def upload_in_last_30_days?
    last_upload = uploads.order(created_at: :desc).limit(1)
    true if last_upload.any? && last_upload.first.created_at.between?(Date.current - 30, Date.current)
  end
end
