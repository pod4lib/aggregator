# frozen_string_literal: true

# :nodoc:
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def home; end

  def api; end

  def show
    render template: "pages/#{params[:id]}"
  end
end
