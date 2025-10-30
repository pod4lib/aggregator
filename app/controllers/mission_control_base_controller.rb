# frozen_string_literal: true

# Configure Mission Control to use cancan authorization.
class MissionControlBaseController < ApplicationController
  before_action :authenticate_user!

  before_action do
    authorize! :access, :mission_control
  end
end
