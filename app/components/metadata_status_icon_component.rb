# frozen_string_literal: true

# Metadata status icon component
class MetadataStatusIconComponent < ViewComponent::Base
  attr_reader :status, :classes, :show_label, :aria_label

  def initialize(status:, classes: '', show_label: false)
    @status = status
    @classes = classes
    @show_label = show_label
    super()
  end

  def icon_class
    Settings.metadata_status[status]&.icon_class
  end

  def label
    Settings.metadata_status[status]&.label
  end
end
