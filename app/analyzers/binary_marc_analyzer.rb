# frozen_string_literal: true

##
# https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html#method-i-metadata
class BinaryMarcAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    largest_possible_marc_record = StringIO.new(blob.service.download_chunk(blob.key, 0..99_999))
    MARC::Reader.new(largest_possible_marc_record, { invalid: :replace }).first
  rescue MARC::Exception
    false
  end

  def metadata
    read_file do |file|
      { analyzer: self.class.to_s, count: file.count }
    end
  rescue MARC::Exception => e
    Rails.logger.info(e)
    Honeybadger.notify(e)

    { analyzer: self.class.to_s, valid: false, error: e.message }
  end

  private

  def read_file
    download_blob_to_tempfile do |file|
      args = { invalid: :replace }
      marc_reader = MARC::Reader.new(file, args)
      yield marc_reader
    end
  end
end
