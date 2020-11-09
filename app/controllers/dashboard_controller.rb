# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  skip_authorization_check only: [:uploads]

  def uploads
    @uploads = Upload.accessible_by(current_ability).order(updated_at: :desc).page(params[:page])
  end
end
