# frozen_string_literal: true

# Controller to handle streams
class StreamsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: %i[make_pending_default]
  skip_authorize_resource only: %i[normalized_dump resourcelist]
  protect_from_forgery with: :null_session, if: :jwt_token

  # rubocop:disable Metrics/AbcSize
  # GET /organizations/1/streams/2
  def show
    @uploads = @stream.uploads.active
    @current_filter = params[:filter]

    if params[:filter].present?
      filter_status = params[:filter].to_sym

      filtered_ids = @uploads.select do |upload|
        upload.files.any? { |file| file.pod_metadata_status == filter_status }
      end.map(&:id)

      @uploads = Upload.where(id: filtered_ids)
    end

    # Reset to page 1 if a filter is applied
    page_number = params[:filter].present? ? 1 : params[:page]
    @uploads = @uploads.order(created_at: :desc).page(page_number)
  end
  # rubocop:enable Metrics/AbcSize

  def resourcelist
    authorize! :read, @stream
    show
    render 'show'
  end

  def new; end

  # GET /organizations/1/streams/2/normalized_data
  def normalized_data; end

  # GET /organizations/1/streams/2/processing_status
  def processing_status; end

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
