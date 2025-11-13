# frozen_string_literal: true

# Controller to handle uploading files to orgs and managing those files
class UploadsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization, except: %i[new create]
  load_and_authorize_resource through: :current_stream, only: %i[new create]
  skip_authorize_resource only: %i[info]
  protect_from_forgery with: :null_session, if: :jwt_token
  helper_method :current_stream

  # GET /uploads
  # GET /uploads.json
  def index # rubocop:disable Metrics/AbcSize
    @current_filter = params[:metadata_status]

    filters = {}
    filters[:created_at] = Time.zone.parse(params[:created_at]).all_day if params[:created_at].present?
    filters[:metadata_status] = @current_filter if @current_filter.present?
    filters[:stream] = current_stream if params[:stream]
    @stream = current_stream
    @uploads = @uploads.active.where(filters).order(created_at: :desc).page(params[:page])

    respond_to do |format|
      format.html { @uploads = @uploads.with_attached_files.order(created_at: :desc).page(index_params[:page]) }
      format.json
    end
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show; end

  # GET /uploads/new
  def new; end

  # POST /uploads
  # POST /uploads.json
  def create
    UploadCreatorService.new(@upload).call
    respond_to do |format|
      if @upload.persisted?
        format.html { redirect_to [@organization, @upload], notice: 'Upload was successfully created.', status: :see_other }
        format.json { render :show, status: :created, location: [@organization, @upload] }
      else
        format.html { render :new }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload.destroy
    respond_to do |format|
      format.html do
        redirect_to organization_uploads_url(@organization), notice: 'Upload was successfully destroyed.', status: :see_other
      end
      format.json { head :no_content }
    end
  end

  def info
    authorize! :read, @upload

    @attachment = @upload.files.find(params[:attachment_id])
    @blob = @attachment.blob
  end

  def current_stream
    @current_stream ||=
      if params[:stream].present?
        slug = @organization.default_stream.normalize_friendly_id(params[:stream])

        @organization.streams.find_or_create_by(slug: slug) do |stream|
          stream.name = params[:stream]
        end
      else
        @organization.default_stream
      end
  end

  private

  def create_params
    upload_params.merge(
      user_id: current_ability&.try(:user)&.id,
      allowlisted_jwts_id: current_ability&.try(:allowlisted_jwt)&.id,
      ip_address: request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    )
  end

  def index_params
    params.permit(:page)
  end

  # Only allow a list of trusted parameters through.
  def upload_params
    params.expect(upload: [:name, :url, { files: [] }]).tap do |p|
      p['files']&.reject!(&:blank?)
      p['url']&.strip!
    end
  end
end
