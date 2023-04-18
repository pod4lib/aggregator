# frozen_string_literal: true

# :nodoc:
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def home
    @overview = Overview.new(current_user)
  end

  def api; end

  def show
    render template: "pages/#{params[:id]}",
           formats: :html # prevents ActionController::MissingExactTemplate triggered by Qualys scan
  end

  def data
    authorize! :read, :pages_data
  end
end
