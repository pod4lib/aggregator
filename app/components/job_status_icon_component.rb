# frozen_string_literal: true

# Job status icon component
class JobStatusIconComponent < ViewComponent::Base
  attr_reader :status, :classes

  def initialize(status:, classes: '')
    @status = status
    @classes = classes
    super()
  end

  def icon_class
    Settings.job_status_group[status]&.icon_class
  end
end
