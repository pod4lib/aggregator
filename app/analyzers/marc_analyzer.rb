# frozen_string_literal: true

##
# https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html#method-i-metadata
class MarcAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    MarcRecordService.new(blob).identify != :unknown
  end

  def metadata
    { analyzer: self.class.to_s, count: reader.count, type: reader.identify }
  rescue MARC::XMLParseError, MARC::Exception => e
    Rails.logger.info(e)
    Honeybadger.notify(e)

    { analyzer: self.class.to_s, valid: false, error: e.message }
  end

  private

  def reader
    @reader ||= MarcRecordService.new(@blob)
  end
end
