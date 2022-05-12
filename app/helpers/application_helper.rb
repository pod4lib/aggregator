# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # refer to https://icons.getbootstrap.com/
  def bootstrap_icon(icon, options = {})
    return unless File.file?("node_modules/bootstrap-icons/icons/#{icon}.svg")

    file = File.read("node_modules/bootstrap-icons/icons/#{icon}.svg")
    content_tag(:span, class: options[:class]) do
      # We trust the HTML provided by the Bootstrap Icons library
      file.html_safe # rubocop:disable Rails/OutputSafety
    end
  end

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

  def default_stream_status_badge(stream)
    # Tooltips are added to <a> elements for accessibility. See https://getbootstrap.com/docs/5.0/components/tooltips/#markup
    content_tag(:a,
                class: 'badge bg-info text-dark text-decoration-none',
                'data-bs-toggle': 'tooltip',
                'data-bs-placement': 'top',
                'data-bs-html': 'true') do
      concat('Default ')
      concat(bootstrap_icon('info-circle-fill', class: 'text-dark'))
      # Add hidden time elements. See application.js
      concat(hidden_time(stream.default_stream_histories.recent[0].start_time, 'default'))
    end
  end

  def previous_default_stream_status_badge(stream)
    # Tooltips are added to <a> elements for accessibility. See https://getbootstrap.com/docs/5.0/components/tooltips/#markup
    content_tag(:a,
                class: 'badge bg-warning text-dark text-decoration-none',
                'data-bs-toggle': 'tooltip',
                'data-bs-placement': 'top',
                'data-bs-html': 'true') do
      concat('Previous default ')
      concat(bootstrap_icon('info-circle-fill', class: 'text-dark'))
      # Add hidden time elements. See application.js
      stream.default_stream_histories.recent.collect do |history|
        next unless history.start_time && history.end_time

        concat(hidden_time(history.start_time, 'start'))
        concat(hidden_time(history.end_time, 'end'))
      end
    end
  end
end
