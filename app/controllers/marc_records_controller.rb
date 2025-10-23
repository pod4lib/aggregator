# frozen_string_literal: true

# Controller to handle MarcRecords
class MarcRecordsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource :stream, through: :organization, optional: true
  load_and_authorize_resource :upload, through: :organization, optional: true
  load_and_authorize_resource through: :organization, except: :index

  before_action :load_marc_records, only: :index

  protect_from_forgery with: :null_session, if: :jwt_token

  def index
    @marc_records = @marc_records.includes(:upload, :file)
                                 .order(file_id: :desc, index: :asc)
                                 .page(index_params[:page])
  end

  def show; end

  def marc21
    response.headers['Content-Disposition'] = "filename=#{@organization.slug}-#{@marc_record.marc001}.mrc"
    render body: @marc_record.marc.to_marc, content_type: 'application/marc'
  end

  def marcxml
    response.headers['Content-Disposition'] = "filename=#{@organization.slug}-#{@marc_record.marc001}.xml"
    render body: @marc_record.marc.to_xml, content_type: 'application/marcxml+xml'
  end

  def index_params
    params.permit(:page, :marc001, :organization_id, :stream_id, :upload_id, :attachment_id)
  end

  def load_marc_records # rubocop:disable Metrics/AbcSize
    @marc_records = @organization.marc_records
    @marc_records = @marc_records.where(marc001: index_params[:marc001]) if index_params[:marc001].present?
    if params[:attachment_id].present?
      @marc_records = @marc_records.where(file: params[:attachment_id])
    elsif @upload
      @marc_records = @marc_records.where(upload: @upload)
    elsif @stream
      @marc_records = @marc_records.where(upload: @stream.uploads)
    end

    @marc_records
  end
end
