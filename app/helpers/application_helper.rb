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
    local_time(time, format: datetime_display_format, class: "hidden-tooltip-time d-none #{time_type}")
  end

  def badge_tooltip_text(history)
    if history.end_time.present?
      concat(hidden_time(history.start_time, 'start'))
      concat(hidden_time(history.end_time, 'end'))
    else
      concat(hidden_time(history.start_time, 'default'))
    end
  end

  def default_stream_status_badge(stream)
    badge_class = stream.default? ? 'bg-info' : 'bg-warning'
    badge_label = stream.default? ? 'Default ' : 'Previous default '

    # Tooltips are added to <a> elements for accessibility.
    # See https://getbootstrap.com/docs/5.0/components/tooltips/#markup
    content_tag(:a,
                href: '#',
                class: "badge text-dark text-decoration-none #{badge_class}",
                'data-bs-toggle': 'tooltip',
                'data-bs-placement': 'top',
                'data-bs-html': 'true') do
      concat(badge_label)
      concat(content_tag(:i, nil, class: 'bi bi-info-circle-fill text-dark'))
      stream.default_stream_histories.recent.collect do |history|
        next unless history.start_time

        badge_tooltip_text(history)
      end
    end
  end
end
