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

  def badge_popover_text(stream)
    if stream.default?
      concat(hidden_time(stream.created_at, 'default'))
    else
      concat(hidden_time(stream.created_at, 'start'))
      concat(hidden_time(stream.updated_at, 'end'))
    end
  end

  def stream_status_badge(stream)
    badge_label = case stream.status
                  when 'default' then 'Default'
                  when 'previous-default' then 'Previous default'
                  end

    return if badge_label.blank?

    # popovers are added to <button> elements for accessibility.
    # See https://getbootstrap.com/docs/5.0/components/popovers
    content_tag(:button,
                href: '#',
                class: "badge text-dark btn #{stream.default? ? 'btn-info' : 'btn-warning'}",
                'data-bs-toggle': 'popover',
                'data-bs-placement': 'top',
                'data-bs-html': 'true') do
      concat(badge_label)
      concat(content_tag(:i, nil, class: 'bi bi-info-circle-fill text-dark'))
      badge_popover_text(stream)
    end
  end
end
