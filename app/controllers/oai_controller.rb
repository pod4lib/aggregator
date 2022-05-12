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
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def render_list_records
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    # unless a resumptionToken is supplied, error if metadataPrefix
    # is anything other than marc21 or empty; per spec
    begin
      unless list_records_params.include?(:resumptionToken)
        md_prefix = list_records_params.require(:metadataPrefix)
        raise OaiConcern::CannotDisseminateFormat unless md_prefix == 'marc21'
      end
    rescue ActionController::ParameterMissing
      raise OaiConcern::BadArgument
    end

    # parse other params
    # TODO: error if dates aren't well-formed?
    from_date = Time.zone.parse(list_records_params[:from]) if list_records_params[:from]
    until_date = Time.zone.parse(list_records_params[:until]) if list_records_params[:until]
    set = list_records_params[:set]
    token = list_records_params[:resumptionToken]

    # token is exclusive; specifying anything else is an error. see the spec
    raise OaiConcern::BadArgument if token && (md_prefix || from_date || until_date || set)

    # if we didn't get a token, generate one based on other arguments
    # NOTE: this way, we can always call next_record_page the same way.
    # ultimately, a token is just a pointer to somewhere in a list of records,
    # and the filters needed to construct that list of records
    token ||= OaiConcern::ResumptionToken.encode(set, nil, from_date, until_date)

    # render the first page of records along with token for the next one
    render xml: build_list_records_response(*next_record_page(token))
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  def render_list_sets
    render xml: build_list_sets_response(Organization.providers)
  end

  def render_identify
    earliest_oai = Stream.default.joins(normalized_dumps: :oai_xml_attachments)
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

  # Get a page of OAI-XML records and a token pointing to the next page
  def next_record_page(token = nil)
    # parse the token if we were provided one
    set, page, from_date, until_date = *OaiConcern::ResumptionToken.decode(token) if token
    page = page.to_i

    # filter normalized dumps and get the corresponding OAI-XML pages
    # NOTE: each page is guaranteed to have < OAIPMHWriter::max_records_per_file,
    # but some pages will have exactly that number and others won't. The sequence
    # isn't predictable; the only thing we promise is that all pages are less than
    # that size.
    pages = normalized_dumps(set, from_date, until_date).flat_map(&:oai_xml_attachments)

    # generate a token for the next page, if there is one
    token = case page
            when (0...pages.count - 1)
              OaiConcern::ResumptionToken.encode(set, page + 1, from_date, until_date)
            when (pages.count - 1)
              nil
            else
              raise OaiConcern::BadResumptionToken
            end

    # return the relevant page and the token for the next page, if any
    [pages[page], token]
  end

  # Get all NormalizedDumps from a particular org or created between two dates
  # NOTE: this likely needs work to memoize/tune, but it should be called
  # repeatedly by next_record_page with the same arguments
  def normalized_dumps(set, from_date, until_date)
    # get candidate streams (all defaults or single org default)
    streams = set ? Stream.default.joins(:organization).where(organization: { slug: set }) : Stream.default

    dumps = filter_dumps(streams, from_date, until_date)

    # error if no dumps match the filters
    raise OaiConcern::NoRecordsMatch if dumps.empty?

    dumps
  end

  def filter_dumps(streams, from_date, until_date)
    # get candidate dumps (the current full dump and its deltas for each stream)
    dumps = streams.flat_map(&:current_dumps).sort_by(&:created_at)

    # filter candidate dumps (by from date and until date)
    dumps = dumps.select { |dump| dump.created_at >= Time.zone.parse(from_date).beginning_of_day } if from_date
    dumps = dumps.select { |dump| dump.created_at <= Time.zone.parse(until_date).end_of_day } if until_date

    dumps
  end

  # Wrap the provided Nokogiri::XML::Builder block in an OAI-PMH response
  # See http://www.openarchives.org/OAI/openarchivesprotocol.html#XMLResponse
  def build_oai_response(xml, params)
    xml.send :'OAI-PMH', oai_xmlns do
      xml.responseDate Time.zone.now.iso8601
      xml.request(params.to_hash) do
        xml.text oai_url
      end
      yield xml
    end
  end

  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords
  def build_list_records_response(page, token = nil)
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, list_records_params do
        xml.ListRecords do
          read_oai_xml(page).each do |chunk|
            xml << chunk
          end
          xml.resumptionToken do
            xml.text token if token
            # NOTE: consider adding completeListSize and cursor (page) here
            # see https://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl
          end
        end
      end
    end.to_xml
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

  # See http://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  def build_list_metadata_formats_response
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, list_metadata_formats_params do
        xml.ListMetadataFormats do
          xml.metadataFormat do
            xml.metadataPrefix 'marc21'
            xml.schema 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd'
            xml.metadataNamespace 'http://www.loc.gov/MARC21/slim'
          end
        end
      end
    end.to_xml
  end

  # See http://www.openarchives.org/OAI/openarchivesprotocol.html#ErrorConditions
  def build_error_response(code, message, params = {})
    Nokogiri::XML::Builder.new do |xml|
      build_oai_response xml, params do
        xml.error(code: code) do
          xml.text message
        end
      end
    end.to_xml
  end

  # Stream an OAI-XML file 1M at a time
  def read_oai_xml(file, chunk_size: 1.megabyte)
    return to_enum(:read_oai_xml, file, chunk_size: chunk_size) unless block_given?

    file.blob.open do |tmpfile|
      io = Zlib::GzipReader.new(tmpfile)

      while (data = io.read(chunk_size))
        yield data
      end

      io.close
    end
  end
end
# rubocop:enable Metrics/ClassLength
