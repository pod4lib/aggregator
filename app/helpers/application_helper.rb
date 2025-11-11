# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  def current_page_class(path)
    'current' if current_page?(path)
  end

  def datetime_display_format
    '%B %e, %Y %l:%M%P %Z'
  end

  def upload_filter_params
    params.permit(:status, :created_at)
  end
end
