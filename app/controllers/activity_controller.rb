# frozen_string_literal: true

# Some site-wide dashboards
class ActivityController < ApplicationController
  authorize_resource class: :controller

  def index
    render Activity::SummaryComponent.new
  end

  def tab
    case params[:tab]
    when 'normalized_data'
      render Activity::NormalizedDataTabComponent.new
    when 'users'
      render Activity::UsersTabComponent.new
    else
      head :not_found
    end
  end
end
