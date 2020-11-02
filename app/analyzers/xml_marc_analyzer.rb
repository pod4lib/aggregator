# frozen_string_literal: true

##
# https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html#method-i-metadata
class XmlMarcAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type.ends_with?('xml') || blob.filename.to_s.include?('xml')
  end

  def metadata
    read_file do |file|
      { count: file.count }
    end
  end

  private

  def read_file
    download_blob_to_tempfile do |file|
      marc_reader = MARC::XMLReader.new(file)
      yield marc_reader
    end
  end
end
