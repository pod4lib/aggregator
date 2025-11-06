# frozen_string_literal: true

# Some site-wide dashboards
class ActivityController < ApplicationController
  authorize_resource class: :controller

  def index
    render Activity::SummaryComponent.new
  end

  def normalized_data
    render Activity::NormalizedDataTabComponent.new
  end

  def uploads
    render Activity::UploadsTabComponent.new
  end

  def users
    render Activity::UsersTabComponent.new
  end
end
