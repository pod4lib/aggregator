# frozen_string_literal: true

# Wrapper around an ActiveStorage blob so we can treat it like an IO
class ActiveStorageBlobIO < DelegateClass(StringIO)
  def initialize(blob)
    @blob = blob
    @blob_pos = 0
    @wrapped = StringIO.new
    super(@wrapped)
  end

  def pos
    @wrapped.pos
  end

  def read(length = nil, outbuffer = nil)
    buffer = +''
    read_length = 0

    while read_length < length
      read_some_more!(length - read_length) if pos + length > @blob_pos

      response = super(length - read_length)

      read_length += response.length
      buffer += response

      break if pos >= size
    end

    outbuffer&.replace(buffer)

    buffer
  end

  def readpartial(length, outbuffer = nil)
    buffer = +''

    response = super(length, buffer) unless @wrapped.eof?

    if response
      outbuffer&.replace(buffer)

      return buffer
    end

    read_some_more!

    buffer += super(length - buffer.length)
    outbuffer&.replace(buffer)
    buffer
  end

  def size
    @blob.byte_size
  end

  def length
    @blob.byte_size
  end

  def read_some_more!(length = nil)
    read_length = 1.kilobyte
    read_length = length if length && length > read_length

    current_pos = pos
    @wrapped.seek(0, IO::SEEK_END)

    chunk = @blob.service.download_chunk(@blob.key, @blob_pos...(@blob_pos + read_length))
    return if chunk.nil?

    @wrapped.write(chunk)
    @blob_pos += chunk.length
    @wrapped.seek(current_pos)
  end
end
