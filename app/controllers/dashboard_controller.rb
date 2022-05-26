# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  authorize_resource class: :controller

  def summary
    @uploads = Upload.recent.page(params[:page])
    @dashboard = Dashboard.new
  end
end
