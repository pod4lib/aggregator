# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :jwt_token
  check_authorization unless: :devise_controller?
  before_action :set_paper_trail_whodunnit

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, jwt_token)
  end

  private

  def jwt_token
    type, token = request.headers['Authorization']&.split(' ')

    token if type == 'Bearer'
  end
end
