# frozen_string_literal: true

# Controller to handle streams
class StreamsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: [:make_default]
  protect_from_forgery with: :null_session, if: :jwt_token

  def show; end

  def removed_since_previous_stream
    render plain: @stream.removed_since_previous_stream.join("\n")
  end

  def make_default
    @stream = @organization.streams.find(params[:stream])
    authorize!(:update, @stream)

    Stream.transaction do
      @organization.default_stream.update(default: false)
      @stream.update(default: true)
    end

    respond_to do |format|
      format.html { redirect_to @organization, notice: 'Stream was successfully updated.' }
      format.json { render :show, status: :ok, location: @organization }
    end
  end
end
