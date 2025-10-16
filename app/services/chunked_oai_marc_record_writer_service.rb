# frozen_string_literal: true

# Utility class for serializing MARC records to files
class ChunkedOaiMarcRecordWriterService
  attr_reader :base_name, :normalized_dump, :now

  def initialize(base_name = nil, dump:, now: Time.zone.now)
    @base_name = base_name
    @normalized_dump = dump
    @now = now
    @counter = 0
    @file_counter = 0
  end

  def current_oai_writer
    @current_oai_writer ||= OaiMarcRecordWriterService.new("#{base_name}-#{format('%010d', @file_counter)}")
  end

  def write_marc_record(record)
    current_oai_writer.write_marc_record(record, now)

    @counter += 1

    write_chunk if (@counter % Settings.oai_max_page_size).zero?
  end

  def write_delete(record)
    current_oai_writer.write_delete(record, now)
    @counter += 1
    write_chunk if (@counter % Settings.oai_max_page_size).zero?
  end

  def write_chunk # rubocop:disable Metrics/AbcSize
    return if @counter.zero?

    @file_counter += 1

    current_oai_writer.finalize
    normalized_dump.oai_xml.attach(io: File.open(current_oai_writer.oai_file),
                                   filename: "oai-#{format('%010d', @file_counter)}.xml.gz")

    do_intermediate_save if (@file_counter % 100).zero?

    @counter = 0
  ensure
    current_oai_writer.close
    current_oai_writer.unlink
    @current_oai_writer = nil
  end

  # perform an intermediate save of the dump to free up file handles
  def do_intermediate_save
    normalized_dump.save!
  end

  def finalize
    write_chunk
  end

  delegate :close, :unlink, to: :@current_oai_writer, allow_nil: true
end
