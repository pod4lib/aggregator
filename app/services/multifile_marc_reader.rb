# frozen_string_literal: true

# handy MARC reader that takes one or more IO streams and outputs marc records
class MultifileMarcReader
  include Enumerable

  def initialize(ios)
    @ios = ios
  end

  def each_raw(limit: 1000, &block)
    return to_enum(:each_raw, limit: limit) unless block

    @ios.each.with_index do |io, idx|
      break if idx > limit

      io.rewind

      reader_for_io(io).each_raw(&block)
    end
  end

  def each(limit: 1000, &block)
    return to_enum(:each, limit: limit) unless block

    @ios.each.with_index do |io, idx|
      break if idx > limit

      io.rewind

      reader_for_io(io).each(&block)
    end
  end

  def reader_for_io(io)
    case MarcRecordService.identify_from_signature(io)
    when :marcxml
      MARC::XMLReader.new(io, parser: 'nokogiri')
    when :marc21
      MARC::Reader.new(io, { external_encoding: 'UTF-8', invalid: :replace })
    end
  end
end
