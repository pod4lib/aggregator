# frozen_string_literal: true

# Produce OAI-PMH responses
class OaiController < ApplicationController
  load_and_authorize_resource :organization

  def show
    if params[:verb] == 'ListRecords'
      render_list_records
    else
      render_error('badVerb')
    end
  end

  private

  def render_list_records
    headers['Cache-Control'] = 'no-cache'
    headers['Last-Modified'] = Time.current.httpdate
    headers['X-Accel-Buffering'] = 'no'

    self.response_body = build_list_records_response(*list_record_normalized_dump_candidates.first(2))
  end

  def render_error(code)
    error = <<-XML
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

  # rubocop:disable Metrics/MethodLength
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
end
