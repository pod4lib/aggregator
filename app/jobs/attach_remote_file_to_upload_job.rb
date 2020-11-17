# frozen_string_literal: true

##
# Job to upload files from a URL in the background
class AttachRemoteFileToUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    io = URI.open(upload.url)
    upload.files.attach(io: io, filename: filename_from_io(io) || filename_from_url(upload.url) || upload.name)
  rescue SocketError, OpenURI::HTTPError => e
    error = "Error opening #{url}: #{e}"
    Rails.logger.info(error)
    Honeybadger.notify(error)
    raise e
  end

  private

  def filename_from_io(io)
    content_disposition = io.meta['content-disposition']&.split(';') || []
    filenames = content_disposition.map do |disp|
      key, value = disp.split('=')
      next unless key == 'filename'

      value
    end.compact

    filenames&.first&.gsub(/^["']|["']$/, '')
  end

  def filename_from_url(url)
    potential_file_name = File.basename(url)

    return unless potential_file_name.include?('.')

    potential_file_name
  end
end
