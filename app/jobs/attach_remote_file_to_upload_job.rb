# frozen_string_literal: true

##
# Job to upload files from a URL in the background
class AttachRemoteFileToUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    io = URI.open(upload.url)
    upload.files.attach(io: io, filename: filename_from_io(io) || upload.name)
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
end
