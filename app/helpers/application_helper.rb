# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  def job_status_tabs_collapse(tab_expanded, jobs_count)
    !tab_expanded && jobs_count.positive? ? 'show' : 'collapsed'
  end

  def current_page_class(path)
    'current' if current_page?(path)
  end

  def datetime_display_format
    '%B %e, %Y %l:%M%P %Z'
  end

  def hidden_time(time, time_type)
    local_time(time, format: datetime_display_format, class: "hidden-popover-time d-none #{time_type}")
  end

  def badge_popover_text(history)
    if history.end_time.present?
      concat(hidden_time(history.start_time, 'start'))
      concat(hidden_time(history.end_time, 'end'))
    else
      concat(hidden_time(history.start_time, 'default'))
    end
  end

  def default_stream_status_badge(stream)
    badge_class = stream.default? ? 'btn-info' : 'btn-warning'
    badge_label = stream.default? ? 'Default ' : 'Previous default '

    # popovers are added to <button> elements for accessibility.
    # See https://getbootstrap.com/docs/5.0/components/popovers
    content_tag(:button,
                href: '#',
                class: "badge text-dark btn #{badge_class}",
                'data-bs-toggle': 'popover',
                'data-bs-placement': 'top',
                'data-bs-html': 'true') do
      concat(badge_label)
      concat(content_tag(:i, nil, class: 'bi bi-info-circle-fill text-dark'))
      stream.default_stream_histories.recent.collect do |history|
        next unless history.start_time

        badge_popover_text(history)
      end
    end
  end
end
