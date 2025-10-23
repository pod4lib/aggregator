Rails.application.config.to_prepare do
  MissionControl::Jobs::ApplicationController.skip_authorization_check
end