# frozen_string_literal: true

# Some site-wide dashboards
class DashboardController < ApplicationController
  skip_authorization_check only: [:uploads]

  content_security_policy only: :uploads do |policy|
    policy.style_src :self, :unsafe_inline
  end

  def uploads
    @uploads = Upload.accessible_by(current_ability).order(updated_at: :desc).page(params[:page])
  end
end
