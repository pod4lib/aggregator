# frozen_string_literal: true

##
# https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html#method-i-metadata
class DeletesAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    MarcRecordService.new(blob).identify == :unknown && blob.content_type == 'text/plain'
  end

  def metadata
    blob.open do |tmpfile|
      { count: tmpfile.each_line.count, type: 'deletes' }
    end
  end
end
