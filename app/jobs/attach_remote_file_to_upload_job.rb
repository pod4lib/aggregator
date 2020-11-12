# frozen_string_literal: true

##
# Job to upload files from a URL in the background
class AttachRemoteFileToUploadJob < ApplicationJob
  queue_as :default

  def perform(upload)
    upload.files.attach(io: URI.open(upload.url), filename: upload.name)
  rescue SocketError, OpenURI::HTTPError => e
    error = "Error opening #{url}: #{e}"
    Rails.logger.info(error)
    Honeybadger.notify(error)
    raise e
  end
end
