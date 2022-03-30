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
end
