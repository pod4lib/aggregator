# frozen_string_literal: true

# :nodoc:
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def home; end

  def api; end
end
