Rails.application.reloader.to_prepare do
  MissionControl::Jobs.base_controller_class = "MissionControlBaseController"
end
