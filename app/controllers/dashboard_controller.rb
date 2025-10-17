# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  authorize_resource class: :controller

  def summary
    render Dashboard::SummaryComponent.new(uploads: uploads)
  end

  def tab
    case params[:tab]
    when 'job_status'
      render Dashboard::JobStatusTabComponent.new
    when 'normalized_data'
      render Dashboard::NormalizedDataTabComponent.new
    when 'users'
      render Dashboard::UsersTabComponent.new
    else
      head :not_found
    end
  end

  private

  def uploads
    @uploads ||= Upload.recent.page(params[:page])
  end
end
