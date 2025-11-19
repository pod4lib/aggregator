# frozen_string_literal: true

# :nodoc:
class Organization < ApplicationRecord
  default_scope { order(name: :asc) }
  resourcify
  extend FriendlyId

  friendly_id :name, use: %i[finders slugged]
  has_paper_trail
  has_many :streams, dependent: :destroy
  has_many :uploads, through: :streams
  has_many :marc_records, through: :streams, inverse_of: :organization
  has_many :allowlisted_jwts, as: :resource, dependent: :delete_all
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_one :contact_email, dependent: :delete
  has_one_attached :icon
  has_many :statistics, dependent: :delete_all, as: :resource
  accepts_nested_attributes_for :contact_email, update_only: true, reject_if: proc { |att| att['email'].blank? }
  has_many :users, -> { distinct }, through: :roles, class_name: 'User', source: :users
  has_many :downloaders, dependent: :destroy
  has_many :downloader_organizations, through: :downloaders, source: :resource, source_type: 'Organization'
  has_many :downloader_groups, through: :downloaders, source: :resource, source_type: 'Group'
  has_many :downloadables, class_name: 'Downloader', as: :resource, dependent: :destroy
  has_many :downloadable_organizations, through: :downloadables, source: :organization
  scope :providers, -> { where(provider: true) }
  scope :consumers, -> { where(provider: false) }
  validates :marc_docs_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # So that Organization.display_name works like other models, such as Group
  alias_attribute :display_name, :name

  def default_stream
    @default_stream ||= streams.find_or_create_by(status: 'default')
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

  def latest_upload
    uploads.recent.first
  end

  def effective_downloadable_organizations
    @effective_downloadable_organizations ||=
      (downloadable_organizations + groups.flat_map(&:downloadable_organizations)).uniq
  end
end
