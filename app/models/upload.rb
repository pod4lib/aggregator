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
      if file.blob.content_type.ends_with?('xml') || file.blob.filename.to_s.ends_with?('xml')
        extract_marc_record_metadata_from_marc_xml(file, &block)
      elsif file.blob.filename.to_s.ends_with?('mrc') || file.blob.filename.to_s.ends_with?('marc')
        extract_marc_record_metadata_from_marc_binary(file, &block)
      else
        # don't process
      end
    end
  end

  def extract_marc_record_metadata_from_marc_binary(file)
    return to_enum(:extract_marc_record_metadata_from_marc_binary, file) unless block_given?

    file.blob.open do |tmpfile|
      args = { invalid: :replace }

      marc_reader = MARC::Reader.new(tmpfile, args)

      each_with_bytecount(marc_reader).with_index do |(bytes, bytecount, length), index|
        record = MARC::Reader.decode(bytes)

        marc = MarcRecord.new(marc001: record['001']&.value,
          file_id: file.id,
          upload_id: id,
          bytecount: bytecount,
          length: length,
          index: index,
          checksum: Digest::MD5.hexdigest(bytes),
          marc: record)

        yield(marc)
      end
    end

    def extract_marc_record_metadata_from_marc_xml(file)
      return to_enum(:extract_marc_record_metadata_from_marc_xml, file) unless block_given?

      file.blob.open do |tmpfile|
        marc_reader = MARC::XMLReader.new(tmpfile, parser: 'nokogiri')

        marc_reader.each.with_index do |record, index|
          marc = MarcRecord.new(marc001: record['001']&.value,
          file_id: file.id,
          upload_id: upload.id,
          index: index,
          checksum: Digest::MD5.hexdigest(record.to_xml.to_s),
          marc: record)

          yield(marc)
        end
      end
    end

  end

  private
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
