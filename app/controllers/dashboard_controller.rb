# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  authorize_resource class: :controller

  def index
    render Dashboard::SummaryComponent.new
  end

  def tab
    case params[:tab]
    when 'normalized_data'
      render Dashboard::NormalizedDataTabComponent.new
    when 'users'
      render Dashboard::UsersTabComponent.new
    else
      head :not_found
    end
  end
end
