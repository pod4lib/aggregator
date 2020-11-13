# frozen_string_literal: true

# Controller to handle MarcRecords
class MarcRecordsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization
  protect_from_forgery with: :null_session, if: :jwt_token

  def show; end

  def index; end
end
