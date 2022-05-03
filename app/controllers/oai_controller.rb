# frozen_string_literal: true

# Produce OAI-PMH responses
# rubocop:disable Metrics/ClassLength
class OaiController < ApplicationController
  include OaiConcern

  skip_authorization_check
  rescue_from OaiConcern::OaiError, with: :render_error

  def show
    verb = params.require(:verb)
    send("render_#{verb.underscore}")
  rescue ActionController::ParameterMissing
    raise OaiConcern::BadVerb
  end

  def method_missing(method, *_args, &_block)
    raise OaiConcern::BadVerb if method.to_s.start_with?('render_')

    super
  end

  def respond_to_missing?(method, include_private = false)
    method.to_s.start_with?('render_') || super
  end

  private

  # rubocop:disable Metrics/AbcSize
  def render_list_records
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    @organization = Organization.find_by(slug: list_records_params[:set])
    @stream = @organization.default_stream
    authorize! :read, @stream

    render xml: build_list_records_response(*list_record_normalized_dump_candidates.first(2))
  end
  # rubocop:enable Metrics/AbcSize

  def render_list_sets
    render xml: build_list_sets_response(Organization.providers)
  end

  def render_identify
    earliest_oai = Stream.default.joins(normalized_dumps: :oai_xml_attachment)
                         .order('normalized_dumps.created_at ASC')
                         .limit(1)
                         .pick('normalized_dumps.created_at')

    render xml: build_identify_response(earliest_oai || Time.now.utc)
  end

  def render_list_metadata_formats
    render xml: build_list_metadata_formats_response
  end

  # Render an error response.
  def render_error(exception)
    code = exception.class.name.demodulize.camelize(:lower)

    # Don't render request params for badArgument or badVerb, as per the spec
    if %w[badArgument badVerb].include?(code)
      render xml: build_error_response(code, exception.message)
    else
      render xml: build_error_response(code, exception.message, params.permit!)
    end
  end

  # Return valid OAI-PMH arguments or raise BadArgument if any are invalid.
  def oai_params(*permitted_params)
    raise OaiConcern::BadArgument unless params.except(:controller, :action, *permitted_params).empty?

    params.permit(*permitted_params)
  end

  def list_records_params
    oai_params(:verb, :from, :until, :set, :resumptionToken, :metadataPrefix)
  end

  def list_sets_params
    oai_params(:verb, :resumptionToken)
  end

  def list_metadata_formats_params
    oai_params(:verb, :identifier)
  end

  def identify_params
    oai_params(:verb)
  end

  # rubocop:disable Metrics/AbcSize
  def list_record_normalized_dump_candidates
    @list_record_normalized_dump_candidates ||= begin
      current_full_dump = @stream.current_full_dump

      dumps = @stream.normalized_dumps.where(id: current_full_dump.id).or(current_full_dump.deltas).order(:created_at)

      if list_records_params[:from]
        dumps = dumps.where(created_at: (Time.zone.parse(list_records_params[:from]).beginning_of_day)...)
      end
      dumps = dumps.where(created_at: ...(Time.zone.parse(list_records_params[:until]).end_of_day)) if list_records_params[:until]
      dumps = dumps.where(id: list_records_params[:resumptionToken]...) if list_records_params[:resumptionToken]

      dumps
    end
  end
  # rubocop:enable Metrics/AbcSize

  # Wrap the provided Nokogiri::XML::Builder block in an OAI-PMH response
  def build_oai_response(xml, params)
    xml.send :'OAI-PMH', oai_xmlns do
      xml.responseDate Time.zone.now.iso8601
      xml.request(params.to_hash) do
        xml.text oai_url
      end
      yield xml
    end
  end

  # rubocop:disable Metrics/MethodLength
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords
  def build_list_records_response(dump, next_dump = nil)
    Enumerator.new do |yielder|
      yielder << <<~EOXML
        <?xml version="1.0" encoding="UTF-8"?>
        <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
                http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
          <responseDate>#{Time.zone.now.iso8601}</responseDate>
          #{build_request.to_xml}
          <ListRecords>
      EOXML

      read_oai_xml(dump).each do |chunk|
        yielder << chunk
      end

      yielder << "<resumptionToken>#{next_dump.id}</resumptionToken>" if next_dump

      yielder << <<~EOXML
          </ListRecords>
        </OAI-PMH>
      EOXML
    end
  end

  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListSets
  def build_list_sets_response(organizations)
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, list_sets_params do
        xml.ListSets do
          organizations.each do |organization|
            xml.set do
              xml.setSpec organization.slug
              xml.setName organization.name
            end
          end
        end
      end
    end.to_xml
  end

  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  def build_identify_response(earliest_date)
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, identify_params do
        xml.Identify do
          xml.repositoryName t('layouts.application.title')
          xml.baseURL oai_url
          xml.protocolVersion '2.0'
          xml.earliestDatestamp earliest_date.strftime('%F')
          xml.deletedRecord 'transient'
          xml.granularity 'YYYY-MM-DD'
          xml.adminEmail Settings.contact_email
        end
      end
    end.to_xml
  end
  # rubocop:enable Metrics/MethodLength

  def build_error_response(code, message, params = {})
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, params do
        xml.error(code: code) do
          xml.text message
        end
      end
    end.to_xml
  end

  def read_oai_xml(dump, chunk_size: 1.megabyte)
    return to_enum(:read_oai_xml, dump, chunk_size: chunk_size) unless block_given?

    dump.oai_xml.attachment.blob.open do |tmpfile|
      io = Zlib::GzipReader.new(tmpfile)

      while (data = io.read(chunk_size))
        yield data
      end

      io.close
    end
  end
end
# rubocop:enable Metrics/ClassLength
