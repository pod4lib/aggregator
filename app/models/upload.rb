# frozen_string_literal: true

# :nodoc:
class Upload < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_paper_trail
  belongs_to :stream, touch: true
  has_one :organization, through: :stream
  has_many :marc_records, dependent: :delete_all
  belongs_to :user, optional: true
  belongs_to :allowlisted_jwts, class_name: 'AllowlistedJwt', optional: true
  belongs_to :compacted_upload, class_name: 'Upload', optional: true
  has_many :compacted_uploads, class_name: 'Upload', inverse_of: :compacted_upload, foreign_key: 'compacted_upload_id',
                               dependent: :destroy_async

  validate :url_presence_if_no_uploaded_files
  validates :files, presence: true, if: proc { |upload| upload.url.blank? && upload.status != 'compacted' }
  validate :valid_url, if: proc { |upload| upload.url.present? && upload.status != 'compacted' }
  scope :active, -> { where(status: %w[active compacted processed]) }
  scope :archived, -> { where(status: 'archived') }
  scope :obsolete, -> { where(status: 'obsolete') }
  scope :recent, -> { order(created_at: :desc) }

  def content_type
    super.presence || files.filter_map(&:content_type).uniq.join(', ')
  end

  # This should be _before_ any callbacks that interact with the attached upload
  # See https://github.com/rails/rails/issues/37304
  has_many_attached :files
  after_touch :update_files_byte_size, :update_files_metadata_status

  def update_files_byte_size
    attachments = files_attachments.includes(:blob)

    total_byte_size = attachments.sum { |file| file.blob.byte_size }
    content_type = attachments.map { |file| file.blob.content_type }.uniq.join(', ')
    update(total_byte_size: total_byte_size, content_type: content_type)
  end

  def active?
    status == 'active'
  end

  def processed?
    status == 'processed'
  end

  def name
    super.presence || created_at&.iso8601
  end

  def obsolete!
    update(status: 'obsolete')
    marc_records.delete_all
  end

  def archive
    update(status: 'archived')
    marc_records.delete_all
    files.find_each(&:purge_later)
  end

  # rubocop:disable Metrics/MethodLength
  def read_marc_record_metadata(**, &block)
    return to_enum(:read_marc_record_metadata, **) unless block

    files.each do |file|
      service = MarcRecordService.new(file.blob)

      format = service.identify

      case format
      when :delete
        extract_marc_record_delete_metadata(file, &block)
      when :unknown
        next
      else
        extract_marc_record_metadata(file, service, **, &block)
      end
    rescue StandardError => e
      Honeybadger.notify(e)
      raise if e.instance_of?(ActiveStorage::FileNotFoundError)
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def update_files_metadata_status
    status = if files.any?(&:pod_unknown_format?)
               'unknown'
             elsif files.all?(&:pod_ok_format?)
               'success'
             else
               'needs_attention'
             end

    update(metadata_status: status)
  end

  def url_presence_if_no_uploaded_files
    return if status == 'compacted'

    errors.add(:url, 'A URL must be provided if a file has not been uploaded') if !files.attached? && url.blank?
  end

  def valid_url
    return if status == 'compacted'

    errors.add(:url, 'Unable to attach file from URL') unless URI.parse(url)&.host
  end

  def extract_marc_record_delete_metadata(file)
    return to_enum(:extract_marc_record_delete_metadata, file) unless block_given?

    file.blob.open do |tmpfile|
      tmpfile.each_line do |line|
        yield MarcRecord.new(
          marc001: line.strip,
          file: file,
          upload: self,
          status: 'delete'
        )
      end
    end
  end

  def extract_marc_record_metadata(file, service, checksum: true)
    return to_enum(:extract_marc_record_metadata, file, service, checksum: checksum) unless block_given?

    service.each_with_metadata do |record, metadata|
      out = MarcRecord.new(
        **metadata,
        file: file,
        marc: record,
        upload: self
      )

      out.checksum ||= Digest::MD5.hexdigest(record.to_xml_string(fast_but_unsafe: true)) if checksum

      yield out
    end
  end
end
