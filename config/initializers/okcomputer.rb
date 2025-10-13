# frozen_string_literal: true

OkComputer.mount_at = 'status'

OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://localhost:6379/0' })

# Do not track ahoy visits to status check page
Rails.application.config.to_prepare do
  OkComputer::OkComputerController.skip_before_action :track_ahoy_visit
end

# check activestorage by uploading + downloading a file
class ActiveStorageCheck < OkComputer::Check
  def check
    service = ActiveStorage::Blob.service
    str = Time.now.to_i.to_s
    service.upload('.healthcheck', StringIO.new(str))
    service.download('.healthcheck') == str
  end
end
OkComputer::Registry.register 'activestorage', ActiveStorageCheck.new
