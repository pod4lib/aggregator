# frozen_string_literal: true

# Service class for reading MARC records out of ActiveStorage::Blobs
class MarcRecordService
  include Enumerable

  def self.marc_reader(io, type)
    case type
    when :marcxml
      MARC::XMLReader.new(io, parser: 'nokogiri')
    when :marc21
      MARC::Reader.new(io, { external_encoding: 'UTF-8', invalid: :replace })
    when :marcxml_gzip
      MARC::XMLReader.new(Zlib::GzipReader.new(io), parser: 'nokogiri')
    when :marc21_gzip
      MARC::Reader.new(Zlib::GzipReader.new(io), { external_encoding: 'UTF-8', invalid: :replace })
    else
      raise "Unknown MARC type: #{type}"
    end
  end

  attr_reader :blob

  # @attr [ActiveStorage::Blob] blob
  def initialize(blob)
    @blob = blob
  end

  # Identify what type of MARC is in the blob by reading just a little bit of it
  def identify
    @identify ||= begin
      start = download_chunk(0...5)

      if start.bytes[0] == 0x1F && start.bytes[1] == 0x8B # gzip magic bytes
        identify_gzip
      elsif ['<?xml', '<reco', '<coll'].include? start # xml preamble
        :marcxml
      elsif start.match?(/^\d+$/) # kinda looks like a MARC21 leader...
        :marc21
      else
        :unknown
      end
    end
  end

  def marc21?(type = identify)
    %i[marc21 marc21_gzip].include? type
  end

  def gzipped?(type = identify)
    %i[marc21_gzip marcxml_gzip].include? type
  end

  # Iterate through the records in a file
  def each(&block)
    return to_enum(:each) unless block

    with_reader do |reader|
      if marc21?
        each_combined_record(reader, &block)
      else
        each_raw_record(reader, &block)
      end
    end
  end

  def each_raw_record(reader)
    return to_enum(:each_raw_record, reader) unless block_given?

    reader.each_with_index do |record, index|
      with_honeybadger_context(index: index, marc001: record['001']&.value) do
        yield record
      end
    end
  end

  def each_combined_record(reader)
    return to_enum(:each_combined_record, reader) unless block_given?

    each_raw_record(reader)
      .slice_when { |i, j| i['001'].value != j['001'].value }
      .each do |records_to_combine|
        if records_to_combine.length == 1
          yield records_to_combine.first
        else
          yield merge_records(*records_to_combine)
        end
      end
  end

  # Get the record at a specific index in the file
  def at_index(target)
    each_with_index do |record, index|
      return record if index == target
    end

    nil
  end

  # Get the record at a specific byte range within the file
  def at_bytes(range, merge: false)
    if gzipped?
      blob.open do |tmpfile|
        io = Zlib::GzipReader.new(tmpfile)

        fake_seek(io, range.first)

        extracted_type = case identify
                         when :marc21_gzip then :marc21
                         when :marcxml_gzip then :marcxml
                         else identify
                         end

        from_bytes(io.read(range.size), extracted_type, merge: merge)
      end
    else
      from_bytes(download_chunk(range), merge: merge)
    end
  end

  # "seek" to the start of the record we're interested in
  def fake_seek(io, pos, chunk_size: 1.megabyte)
    return io.seek(pos) if io.respond_to? :seek

    (pos / chunk_size).times { io.read(chunk_size) }
    io.read(pos % chunk_size)

    nil
  end

  # Get a reader for a already-known range of bytes
  def from_bytes(bytes, type = nil, merge: false)
    reader = self.class.marc_reader(StringIO.new(bytes), type || identify)

    return reader unless marc21?(type || identify) && merge

    merge_records(*reader.each.to_a)
  end

  # Optimization for counting records in a file
  # @return [Number]
  def count(*args, &block)
    super if args.any? || block

    if marc21?
      # TODO: cheat if we're just counting records?
      with_reader { |reader| reader.each_raw.count }
    else
      super
    end
  end

  # Iterate through the records in a file and yield the record plus some additional metadata
  # about the location + context of the record
  def each_with_metadata(&block)
    return to_enum(:each_with_metadata) unless block

    return each_with_metadata_for_marc21(&block) if marc21?

    each.with_index { |record, index| yield record, { index: index } }
  end

  private

  def with_reader
    blob.open do |tmpfile|
      with_honeybadger_context do
        yield reader(tmpfile)
      end
    end
  end

  def reader(io)
    self.class.marc_reader(io, identify)
  end

  # rubocop:disable Metrics/AbcSize
  def each_with_metadata_for_marc21
    return to_enum(:each_with_metadata_for_marc21) unless block_given?

    each_raw_record_with_metadata_for_marc21
      .slice_when { |i, j| i[:marc]['001'].value != j[:marc]['001'].value }
      .each_with_index do |records_to_combine, index|
      if records_to_combine.length == 1
        yield(records_to_combine.first[:marc], records_to_combine.first.except(:marc))
      else
        bytes = records_to_combine.pluck(:marc_bytes).join('')

        record = merge_records(*records_to_combine.pluck(:marc))

        yield record, {
          **records_to_combine.first.except(:marc, :marc_bytes),
          index: index,
          length: bytes.length,
          checksum: Digest::MD5.hexdigest(bytes)
        }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def each_raw_record_with_metadata_for_marc21
    return to_enum(:each_raw_record_with_metadata_for_marc21) unless block_given?

    with_reader do |reader|
      bytecount = 0
      reader.each_raw.with_index do |bytes, index|
        with_honeybadger_context(bytecount: bytecount, index: index) do
          length = bytes[0...5].to_i
          record = MARC::Reader.decode(bytes)
          with_honeybadger_context(marc001: record['001']&.value, bytecount: bytecount, index: index) do
            yield(
              bytecount: bytecount,
              length: length,
              index: index,
              checksum: Digest::MD5.hexdigest(bytes),
              marc_bytes: bytes,
              marc: record
            )
            bytecount += length
          end
        end
      end
    end
  end

  def identify_gzip
    reader = Zlib::GzipReader.new(StringIO.new(download_chunk(0...1024)))
    inner_start = reader.read(5)

    case inner_start
    when '<?xml' then :marcxml_gzip
    when /^\d+$/ then :marc21_gzip
    else :unknown
    end
  end

  def download_chunk(range)
    blob.service.download_chunk(blob.key, range)
  end

  def with_honeybadger_context(**context)
    Honeybadger.context((Honeybadger.get_context || {}).merge(marc_record: { blob: blob.id, **context }))

    yield(context).tap do
      Honeybadger.context((Honeybadger.get_context || {}).except(:marc_record))
    end
  end

  # rubocop:disable Metrics/AbcSize
  def merge_records(first_record, *other_records)
    return first_record if other_records.blank?

    record = MARC::Record.new

    record.leader = first_record.leader
    record.instance_variable_get(:@fields).concat(first_record.instance_variable_get(:@fields))

    other_records.each do |r|
      record.instance_variable_get(:@fields).concat(r.instance_variable_get(:@fields).reject do |field|
        field.tag < '010' ||
        field.tag > '841' ||
        record.instance_variable_get(:@fields).include?(field)
      end)

      # holdings... don't even try
      record.instance_variable_get(:@fields).concat(r.fields(('841'..'889').to_a))

      # local fields..
      record.instance_variable_get(:@fields).concat(r.fields(('900'..'999').to_a))
    end

    record.instance_variable_get(:@fields).reindex
    record
  end
  # rubocop:enable Metrics/AbcSize
end
