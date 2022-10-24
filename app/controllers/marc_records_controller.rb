# frozen_string_literal: true

# Controller to handle MarcRecords
class MarcRecordsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization
  protect_from_forgery with: :null_session, if: :jwt_token

  def index
    @marc_records = @marc_records.where(marc001: index_params[:marc001]) if index_params[:marc001]
    if index_params[:stream]
      stream = @organization.streams.find_by(slug: index_params[:stream])
      @marc_records = @marc_records.where(upload: stream.uploads)
    end
    @marc_records = @marc_records.page(index_params[:page])
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
    params.permit(:page, :marc001, :stream)
  end
end
