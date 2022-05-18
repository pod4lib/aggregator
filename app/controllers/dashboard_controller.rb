# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  authorize_resource class: :controller

  def summary
    @uploads = Upload.recent.accessible_by(current_ability).page(params[:page])
    @recent_uploads_by_provider = Upload.recent.where('created_at > ?', 30.days.ago).group_by(&:organization)
    @job_status_groups_by_provider = Organization.providers.index_with { |org| org.default_stream.job_tracker_status_groups }
  end
end
