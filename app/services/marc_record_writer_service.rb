# frozen_string_literal: true

# Utility class for serializing MARC records to files
class MarcRecordWriterService
  attr_reader :base_name, :files

  def initialize(base_name = nil, files: { errata: nil, marcxml: nil, marc21: nil, deletes: nil })
    @base_name = base_name
    @files = files.compact
    @opened_files = []
    @writers = {}
  end

  def write_marc_record(record)
    write_errata("#{record.marc001}: Invalid record") and return unless valid?(record)

    write_marc21_record(record)
    write_marcxml_record(record)
  end

  def write_delete(record)
    deletes_writer.puts(record.marc001)
  end

  def write_errata(message)
    writer(:errata).puts(message)
  end

  def finalize
    @writers.each_value(&:close)
  end

  def close
    @opened_files.each(&:close)
  end

  def unlink
    @opened_files.each(&:unlink)
  end

  private

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

  def gzipped_temp_file(name)
    Zlib::GzipWriter.new(temp_file(name))
  end

  def temp_file(name)
    Tempfile.new("#{base_name}-#{name}", binmode: true).tap do |file|
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
end
