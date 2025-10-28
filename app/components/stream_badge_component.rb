# frozen_string_literal: true

# Stream badge component
class StreamBadgeComponent < ViewComponent::Base
  attr_reader :stream

  delegate :local_time, :datetime_display_format, to: :helpers

  def initialize(stream:)
    @stream = stream
    super()
  end

  def hidden_time(time, time_type)
    local_time(time, format: datetime_display_format, class: "hidden-popover-time d-none #{time_type}")
  end

  def popover_text
    if stream.default?
      hidden_time(stream.created_at, 'default')
    else
      safe_join [hidden_time(stream.created_at, 'start'), hidden_time(stream.updated_at, 'end')]
    end
  end

  def render?
    badge_label.present?
  end

  def badge_label
    case stream.status
    when 'default' then 'Default'
    when 'previous-default' then 'Previous default'
    end
  end

  def status_class
    case stream.status
    when 'default' then 'btn-info'
    else 'btn-warning'
    end
  end

  def info_icon
    tag.i class: 'bi bi-info-circle-fill text-dark'
  end
end
