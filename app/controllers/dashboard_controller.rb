# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  authorize_resource class: :controller

  def uploads
    @uploads = Upload.accessible_by(current_ability).page(params[:page])
  end
end
