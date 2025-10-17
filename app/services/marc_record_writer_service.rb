# frozen_string_literal: true

# Utility class for serializing MARC records to files
class MarcRecordWriterService # rubocop:disable Metrics/ClassLength
  attr_reader :base_name, :files, :dump, :now

  def initialize(base_name = nil, dump:, now: Time.zone.now, files: { errata: nil, marcxml: nil, marc21: nil, deletes: nil })
    @base_name = base_name
    @dump = dump
    @now = now
    @files = files.compact
    @opened_files = []
    @writers = {}
  end

  def write_marc_record(record)
    write_errata("#{record.marc001}: Invalid record") and return unless valid?(record)

    write_marc21_record(record)
    write_marcxml_record(record)
    write_oai_record(record)
  end

  def write_delete(record)
    deletes_writer.puts(record.marc001)
    oai_writer.write_delete(record)
  end

  def write_errata(message)
    writer(:errata).puts(message)
  end

  def finalize
    oai_writer.finalize

    @writers.each_value(&:close)

    files.each do |as, file|
      dump.public_send(as).attach(io: File.open(file), filename: human_readable_filename(base_name, as))
    end
  end

  def close
    @opened_files.each(&:close)

    oai_writer.close
  end

  def unlink
    @opened_files.each(&:unlink)
    oai_writer.unlink

    FileUtils.rm_rf tempdir
  end

  private

  def write_oai_record(record)
    oai_writer.write_marc_record(record)
  rescue StandardError => e
    write_errata("#{record.marc001}: #{e}")
  end

  def write_marc21_record(record)
    writer(:marc21).write(split_marc(record.augmented_marc))
  rescue StandardError => e
    write_errata("#{record.marc001}: #{e}")
  end

  def write_marcxml_record(record)
    marcxml_writer.write(record.augmented_marc)
  rescue StandardError => e
    write_errata("#{record.marc001}: #{e}")
  end

  def file(type)
    @files[type] ||= temp_file(type)
  end

  def writer(type)
    @writers[type] ||= Zlib::GzipWriter.new(file(type))
  end

  def marcxml_writer
    @writers[:marcxml] ||= OxMarcXmlWriter.new(Zlib::GzipWriter.new(file(:marcxml)))
  end

  def deletes_writer
    @writers[:deletes] ||= file(:deletes)
  end

  def oai_writer
    @writers[:oai] ||= ChunkedOaiMarcRecordWriterService.new(base_name, dump: dump, now: now)
  end

  def gzipped_temp_file(name)
    Zlib::GzipWriter.new(temp_file(name))
  end

  def temp_file(name)
    Tempfile.new("#{base_name}-#{name}", tempdir, binmode: true).tap do |file|
      @opened_files << file
    end
  end

  def split_marc(marc)
    marc.to_marc
  rescue MARC::Exception => e
    return CustomMarcWriter.encode(marc) if e.message.include? "Can't write MARC record in binary format, as a length/offset"

    raise e
  end

  def valid?(record)
    record.marc.none? do |field|
      case field
      when MARC::ControlField
        field.value.include?("\uFFFD")
      when MARC::DataField
        field.subfields.any? { |sf| sf.value.include?("\uFFFD") }
      end
    end
  end

  def tempdir
    @tempdir ||= Dir.mktmpdir(base_name || 'marc_record_writer', Settings.marc_record_writer_tmpdir || Dir.tmpdir)
  end

  def human_readable_filename(base_name, file_type)
    as = case file_type
         when :deletes
           'deletes.del.txt'
         when :marc21
           'marc21.mrc.gz'
         when :marcxml
           'marcxml.xml.gz'
         else
           "#{file_type}.gz"
         end

    "#{base_name}-#{as}"
  end
end
