# frozen_string_literal: true

# Controller to handle streams
class StreamsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: [:make_default]
  protect_from_forgery with: :null_session, if: :jwt_token

  def show; end

  def new; end

  # POST /streams
  # POST /streams.json
  def create
    @stream = Stream.new(stream_params)

    respond_to do |format|
      if @stream.save
        format.html { redirect_to [@organization, @stream], notice: 'Stream was successfully created.' }
        format.json { render :show, status: :created, location: [@organization, @stream] }
      else
        format.html { render :new }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def normalized_dump
    @normalized_dump = @stream.normalized_dumps.last || @stream.normalized_dumps.build
  end

  def destroy
    @stream.destroy

    respond_to do |format|
      format.html { redirect_to organization_streams_path, notice: 'Stream was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

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

  private

  # Only allow a list of trusted parameters through.
  def stream_params
    params.require(:stream).permit(:name, :slug).merge(organization_id: @organization.id)
  end
end
