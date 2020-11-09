# frozen_string_literal: true

# :nodoc:
class Upload < ApplicationRecord
  has_paper_trail
  belongs_to :stream, touch: true
  has_one :organization, through: :stream
  has_many :marc_records, dependent: :delete_all

  has_many_attached :files

  after_commit do
    ExtractMarcRecordMetadataJob.perform_later(self)
  end

  def name
    super.presence || created_at&.iso8601
  end

  def each_marc_record_metadata(&block)
    return to_enum(:each_marc_record_metadata) unless block_given?

    files.each do |file|
      content_type = file.blob.content_type
      filename = file.blob.filename.to_s
      if content_type.ends_with?('xml') || filename.ends_with?('xml')
        extract_marc_record_metadata_from_marc_xml(file, &block)
      elsif filename.ends_with?('mrc') || filename.ends_with?('marc')
        extract_marc_record_metadata_from_marc_binary_with_combining(file, &block)
      end
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def extract_marc_record_metadata_from_marc_binary_with_combining(file)
    return to_enum(:extract_marc_record_metadata_from_marc_binary_with_combining, file) unless block_given?

    extract_marc_record_metadata_from_marc_binary(file)
      .slice_when { |i, j| i.marc['001'].value != j.marc['001'].value }
      .each do |records_to_combine|
      if records_to_combine.length == 1
        yield records_to_combine.first
      else
        bytes = records_to_combine.map(&:marc_bytes).join('')

        yield MarcRecord.new(
          **records_to_combine.first.attributes,
          length: bytes.length,
          checksum: Digest::MD5.hexdigest(bytes),
          marc_bytes: bytes,
          marc: nil
        )
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def extract_marc_record_metadata_from_marc_binary(file)
    return to_enum(:extract_marc_record_metadata_from_marc_binary, file) unless block_given?

    file.blob.open do |tmpfile|
      marc_reader = MARC::Reader.new(tmpfile, { invalid: :replace })

      each_with_bytecount(marc_reader).with_index do |(bytes, bytecount, length), index|
        record = MARC::Reader.decode(bytes)

        yield(
          MarcRecord.new(
            marc001: record['001']&.value,
            file_id: file.id,
            upload_id: id,
            bytecount: bytecount,
            length: length,
            index: index,
            checksum: Digest::MD5.hexdigest(bytes),
            marc_bytes: bytes,
            marc: record
          )
        )
      end
    end
  end

  def extract_marc_record_metadata_from_marc_xml(file)
    return to_enum(:extract_marc_record_metadata_from_marc_xml, file) unless block_given?

    file.blob.open do |tmpfile|
      marc_reader = MARC::XMLReader.new(tmpfile, parser: 'nokogiri')

      marc_reader.each.with_index do |record, index|
        yield(
          MarcRecord.new(
            marc001: record['001']&.value,
            file_id: file.id,
            upload_id: id,
            index: index,
            checksum: Digest::MD5.hexdigest(record.to_xml.to_s),
            marc: record
          )
        )
      end
    end
  end

  def each_with_bytecount(reader)
    return to_enum(:each_with_bytecount, reader) unless block_given?

    bytecount = 0

    reader.each_raw do |bytes|
      length = bytes[0...5].to_i
      yield bytes, bytecount, length
      bytecount += length
    end
  end
end
