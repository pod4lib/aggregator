# frozen_string_literal: true

# Utility class for serializing MARC records to files
class OaiMarcRecordWriterService
  attr_reader :base_name

  def initialize(base_name = nil)
    @base_name = base_name
  end

  def write_marc_record(record, dump_created_at)
    oai_writer.write(record.augmented_marc, oai_id(record), record.stream.id, dump_created_at)
  rescue StandardError => e
    error = "Error writing MARC OAI file #{base_name} id #{record.id}: #{e}"
    Rails.logger.info(error)
    Honeybadger.notify(error)
  end

  def write_delete(record, dump_created_at)
    oai_writer.write_delete(oai_id(record), record.stream.id, dump_created_at)
  end

  def finalize
    @oai_writer&.close
  end

  def close
    @oai_file&.close
  end

  def unlink
    @oai_file&.unlink
  end

  def oai_file
    @oai_file ||= Tempfile.new("#{base_name}-oai_xml", binmode: true)
  end

  def bytes_written?
    @oai_writer&.bytes_written?
  end

  private

  def oai_writer
    @oai_writer ||= OAIPMHWriter.new(Zlib::GzipWriter.new(oai_file))
  end

  # See http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
  def oai_id(record)
    "oai:#{Settings.oai_repository_id}:#{record.organization.slug}:#{record.marc001}"
  end

  # Special logic for writing OAI-PMH-style record responses
  class OAIPMHWriter
    attr_reader :bytes_written

    def initialize(io)
      @io = io
      @bytes_written = 0
    end

    def write(record, identifier, set, datestamp = Time.zone.now)
      @bytes_written += @io.write <<-EOXML
        <record>
          <header>
            <identifier>#{identifier}</identifier>
            <datestamp>#{datestamp.strftime('%F')}</datestamp>
            <setSpec>#{set}</setSpec>
          </header>
          <metadata>
            #{Ox.dump(OxMarcXmlWriter.encode(record, include_namespace: true))}
          </metadata>
        </record>
      EOXML
    end

    def write_delete(identifier, set, datestamp = Time.zone.now)
      @bytes_written += @io.write <<-EOXML
        <record>
          <header status="deleted">
            <identifier>#{identifier}</identifier>
            <datestamp>#{datestamp.strftime('%F')}</datestamp>
            <setSpec>#{set}</setSpec>
          </header>
        </record>
      EOXML
    end

    def bytes_written?
      @bytes_written.positive?
    end

    delegate :close, to: :@io
  end
end
