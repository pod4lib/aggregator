# frozen_string_literal: true

# Service class for reading MARC records out of ActiveStorage::Blobs
class MarcRecordService
  include Enumerable

  attr_reader :blob

  # @attr [ActiveStorage::Blob] blob
  def initialize(blob)
    @blob = blob
  end

  # Identify what type of MARC is in the blob by reading just a little bit of it
  def identify
    @identify ||= begin
      start = download_chunk(0...5)

      if start == '<?xml' # xml preamble
        :marcxml
      elsif start == '<reco' # start of a record (is this even valid?)
        :marcxml
      elsif start.match?(/^\d+$/) # kinda looks like a MARC21 leader...
        :marc21
      else
        :unknown
      end
    end
  end

  def marc21?
    %i[marc21].include? identify
  end

  # Iterate through the records in a file
  def each(&block)
    return to_enum(:each) unless block_given?

    with_reader do |reader|
      reader.each(&block)
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
  def at_bytes(range)
    if identify == :marc21
      from_bytes(download_chunk(range))
    else
      blob.open do |tmpfile|
        seek(range.first)

        from_bytes(tmpfile.read(range.length))
      end
    end
  end

  # Get a reader for a already-known range of bytes
  def from_bytes(bytes)
    reader(StringIO.new(bytes))
  end

  # Optimization for counting records in a file
  # @return [Number]
  def count(*args, &block)
    super if args.any? || block_given?

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
    return to_enum(:each_with_metadata) unless block_given?

    return each_with_metadata_for_marc21(&block) if marc21?

    each.with_index { |record, index| yield record, { index: index } }
  end

  private

  def with_reader
    blob.open do |tmpfile|
      yield reader(tmpfile)
    end
  end

  def reader(io)
    case identify
    when :marcxml
      MARC::XMLReader.new(io, parser: 'nokogiri')
    when :marc21
      MARC::Reader.new(io, { invalid: :replace })
    else
      raise "Unknown MARC type: #{identify}"
    end
  end

  def each_with_metadata_for_marc21
    return to_enum(:each_with_metadata_for_marc21) unless block_given?

    with_reader do |reader|
      bytecount = 0
      reader.each_raw.with_index do |bytes, index|
        length = bytes[0...5].to_i
        record = MARC::Reader.decode(bytes)
        yield record, {
          bytecount: bytecount,
          length: length,
          index: index,
          checksum: Digest::MD5.hexdigest(bytes),
          marc_bytes: bytes
        }
        bytecount += length
      end
    end
  end

  def download_chunk(range)
    blob.service.download_chunk(blob.key, range)
  end
end
