# frozen_string_literal: true

# Utility class for serializing MARC records to files
class OaiMarcRecordWriterService
  attr_reader :base_name

  def initialize(base_name = nil)
    @base_name = base_name
  end

  def write_marc_record(record)
    oai_writer.write(record.augmented_marc, record.oai_id, record.organization.slug, record.upload.created_at)
  rescue StandardError => e
    error = "Error writing MARC OAI file #{record.oai_id}: #{e}"
    Rails.logger.info(error)
    Honeybadger.notify(error)
  end

  def write_delete(record)
    oai_writer.write_delete(record.oai_id, record.organization.slug, record.upload.created_at)
  end

  def finalize
    @oai_writer.close
  end

  def close
    @oai_file.close
  end

  def unlink
    @oai_file.unlink
  end

  def oai_file
    @oai_file ||= Tempfile.new("#{base_name}-oai_xml", binmode: true)
  end

  private

  def oai_writer
    @oai_writer ||= OAIPMHWriter.new(oai_file)
  end

  # Special logic for writing OAI-PMH-style record responses
  class OAIPMHWriter
    def initialize(io)
      @io = io
    end

    def write(record, identifier, set, datestamp = Time.zone.now)
      @io.write <<-EOXML
        <record>
          <header>
            <identifier>#{identifier}</identifier>
            <datestamp>#{datestamp.strftime('%F')}</datestamp>
            <setSpec>#{set}</setSpec>
          </header>
          <metadata>
            #{MARC::XMLWriter.encode(record, include_namespace: true)}
          </metadata>
        </record>
      EOXML
    end

    def write_delete(identifier, set, datestamp = Time.zone.now)
      @io.write <<-EOXML
        <record>
          <header status="deleted">
            <identifier>#{identifier}</identifier>
            <datestamp>#{datestamp.strftime('%F')}</datestamp>
            <setSpec>#{set}</setSpec>
          </header>
        </record>
      EOXML
    end

    def close
      @io.close
    end
  end
end
