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
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  has_many :allowed_consumers, dependent: :destroy
  has_many :allowed_consumer_organizations, through: :allowed_consumers, source: :allowed_consumer, source_type: 'Organization'
  has_many :allowed_consumer_groups, through: :allowed_consumers, source: :allowed_consumer, source_type: 'Group'

  has_many :received_allowed_consumers, class_name: 'AllowedConsumer', as: :allowed_consumer, dependent: :destroy
  has_many :allowed_to_consume_organizations, through: :received_allowed_consumers, source: :organization

  has_one :contact_email, dependent: :delete
  has_one_attached :icon
  has_many :statistics, dependent: :delete_all, as: :resource
  accepts_nested_attributes_for :contact_email, update_only: true, reject_if: proc { |att| att['email'].blank? }
  has_many :users, -> { distinct }, through: :roles, class_name: 'User', source: :users
  scope :providers, -> { where(provider: true) }
  scope :consumers, -> { where(provider: false) }
  scope :unrestricted, -> { where.not(id: AllowedConsumer.select(:organization_id).distinct).where(record_access: 'authenticated_users') }

  validates :marc_docs_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  enum :record_access, { authenticated_users: 'authenticated_users', managed: 'managed' }

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

  def most_recent_upload
    upload = uploads.order(created_at: :desc).limit(1)
    upload.any? ? upload : nil
  end

  def upload_in_last_30_days?
    most_recent_upload && most_recent_upload.first.created_at.between?(30.days.ago, Time.zone.now)
  end

  def allowed_to_consume_organization_ids
    allowed_to_consume_organizations.pluck(:id)
                                    .concat(Organization.unrestricted.pluck(:id))
                                    .concat(groups.flat_map(&:allowed_to_consume_organizations).pluck(:id))
  end
end
