# frozen_string_literal: true

# Produce OAI-PMH responses
# rubocop:disable Metrics/ClassLength
class OaiController < ApplicationController
  load_and_authorize_resource :organization

  def show
    case params[:verb]
    when 'ListRecords'
      render_list_records
    when 'ListSets'
      render_list_sets
    when 'Identify'
      render_identify
    else
      render_error('badVerb')
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def render_list_records
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    @organization = Organization.find_by(slug: params[:set])
    @stream = @organization.default_stream
    authorize! :read, @stream

    render xml: build_list_records_response(*list_record_normalized_dump_candidates.first(2))
  end
  # rubocop:enable Metrics/AbcSize

  def render_list_sets
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    render xml: build_list_sets_response(Organization.providers)
  end

  def render_identify
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    render xml: build_identify_response(Upload.order(:created_at).first.created_at)
  end

  def render_error(code)
    error = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
              http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
        <responseDate>#{Time.zone.now.iso8601}</responseDate>
        #{build_request.to_xml}
        <error code="#{code}" />
      </OAI-PMH>
    XML

    render xml: error
  end

  def build_request
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.request(oai_params.to_hash) do
        xml.text oai_url
      end
    end

    Nokogiri::XML(builder.to_xml).root
  end

  def oai_params
    params.permit(:verb, :from, :until, :set, :resumptionToken, :metadataPrefix)
  end

  # rubocop:disable Metrics/AbcSize
  def list_record_normalized_dump_candidates
    @list_record_normalized_dump_candidates ||= begin
      current_full_dump = @stream.current_full_dump

      dumps = @stream.normalized_dumps.where(id: current_full_dump.id).or(current_full_dump.deltas).order(:created_at)

      dumps = dumps.where(created_at: (Time.zone.parse(params[:from]).beginning_of_day)...) if params[:from]
      dumps = dumps.where(created_at: ...(Time.zone.parse(params[:until]).end_of_day)) if params[:until]
      dumps = dumps.where(id: params[:resumptionToken]...) if params[:resumptionToken]

      dumps
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
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
      xml.send :'OAI-PMH', oai_xmlns do
        xml.responseDate Time.zone.now.iso8601
        xml.request(oai_params.to_hash) do
          xml.text oai_url
        end
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
      xml.send :'OAI-PMH', oai_xmlns do
        xml.responseDate Time.zone.now.iso8601
        xml.request(oai_params.to_hash) do
          xml.text oai_url
        end
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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

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

  # XML namespace values for OAI-PMH, see:
  # https://www.openarchives.org/OAI/openarchivesprotocol.html#XMLResponse
  def oai_xmlns
    {
      'xmlns' => 'http://www.openarchives.org/OAI/2.0/',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd'
    }
  end
end
# rubocop:enable Metrics/ClassLength
