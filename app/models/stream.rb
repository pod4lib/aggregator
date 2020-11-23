# frozen_string_literal: true

# :nodoc:
class Stream < ApplicationRecord
  has_paper_trail
  extend FriendlyId
  friendly_id :name, use: %i[finders slugged scoped], scope: :organization
  belongs_to :organization
  has_many :uploads, dependent: :destroy
  has_many :marc_records, through: :uploads
  has_many :files, source: :files_blobs, through: :uploads
  has_one :statistic, dependent: :delete, as: :resource
  has_many :normalized_dumps, dependent: :destroy
  has_many :job_trackers, dependent: :delete_all, as: :reports_on

  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }

  has_many_attached :snapshots

  def display_name
    name.presence || default_name
  end

  def archive
    update(status: 'archived', default: false)
    uploads.find_each(&:archive)
  end

  def removed_since_previous_stream
    all_other_marc_records = organization.marc_records.select(:marc001).where.not(streams: { id: id })
    this_stream_marc_records = marc_records.select(:marc001)
    except_stream = all_other_marc_records.arel.except(this_stream_marc_records.arel)

    MarcRecord.from(MarcRecord.arel_table.create_table_alias(except_stream, :marc_records)).pluck(:marc001)
  end

  private

  def default_name
    "#{I18n.l(created_at.to_date)} - #{default? ? '' : I18n.l(updated_at.to_date)}"
  end
end
