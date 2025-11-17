# frozen_string_literal: true

# Controller to handle streams
class StreamsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: %i[make_pending_default]
  skip_authorize_resource only: %i[normalized_dump resourcelist normalized_data processing_status]
  protect_from_forgery with: :null_session, if: :jwt_token

  def show; end

  def resourcelist
    authorize! :read, @stream
    show
    render 'show'
  end

  def new; end

  # GET /organizations/1/streams/2/normalized_data
  def normalized_data
    authorize! :read, @stream
  end

  def enqueue_full_dump
    authorize! :manage, @stream

    GenerateFullDumpJob.perform_later(@stream)

    respond_to do |format|
      format.html { redirect_back_or_to([@organization, @stream], notice: 'Full dump job was successfully enqueued.') }
      format.json { render :show, status: :ok, location: [@organization, @stream] }
    end
  end

  def enqueue_delta_dump
    authorize! :manage, @stream
    GenerateDeltaDumpJob.perform_later(@stream)
    respond_to do |format|
      format.html { redirect_back_or_to([@organization, @stream], notice: 'Delta dump job was successfully enqueued.') }
      format.json { render :show, status: :ok, location: [@organization, @stream] }
    end
  end

  # GET /organizations/1/streams/2/processing_status
  def processing_status
    authorize! :read, @stream
  end

  # POST /streams
  # POST /streams.json
  def create
    @stream = Stream.new(stream_params)

    respond_to do |format|
      if @stream.save
        format.html { redirect_to [@organization, @stream], notice: 'Stream was successfully created.', status: :see_other }
        format.json { render :show, status: :created, location: [@organization, @stream] }
      else
        format.html { render :new }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @stream.destroy

    respond_to do |format|
      format.html { redirect_to organization_streams_path, notice: 'Stream was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  def normalized_dump
    authorize! :read, @stream

    @normalized_dump = @stream.full_dumps.published.last || @stream.full_dumps.build
  end

  def make_pending_default
    @stream = @organization.streams.find(params[:stream])
    authorize!(:update, @stream)

    @stream.make_pending

    respond_to do |format|
      format.html { redirect_to @organization, notice: 'Stream was successfully updated.', status: :see_other }
      format.json { render :show, status: :ok, location: @organization }
    end
  end

  def reanalyze
    ReanalyzeJob.perform_later(@stream)

    respond_to do |format|
      format.html { redirect_back_or_to([@organization, @stream], notice: 'Reanalyze job was successfully enqueued.') }
      format.json { render :show, status: :ok, location: [@organization, @stream] }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def stream_params
    params.expect(stream: %i[name slug]).merge(organization_id: @organization.id)
  end
end
