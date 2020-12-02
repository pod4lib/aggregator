# frozen_string_literal: true

##
# Background job to create a full dump download for a resource (organization)
class ReanalyzeJob < ApplicationJob
  def self.enqueue_all
    Stream.find_each { |stream| ReanalyzeJob.perform_later(stream) }
  end

  def perform(target)
    case target
    when Stream
      target.uploads.find_each { |x| ReanalyzeJob.perform_later(x) }
    when Upload
      ExtractMarcRecordMetadataJob.perform_later(target)
      target.files.find_each { |x| ReanalyzeJob.perform_later(x.blob) }
    when ActiveStorage::Blob
      target.analyze_later
    end
  end
end
