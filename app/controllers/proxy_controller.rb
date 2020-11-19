# frozen_string_literal: true

##
# Proxying over ActiveStorage so we can have sane routes.
# Waiting on https://github.com/rails/rails/commit/dfb5a82b259e134eac89784ac4ace0c44d1b4aee
class ProxyController < ActiveStorage::BaseController
  include CustomPodAbilityConcern
  include JwtTokenConcern

  protect_from_forgery with: :null_session, if: :jwt_token
  before_action :authenticate_user!, unless: :jwt_token

  rescue_from ActiveStorage::FileNotFoundError do |exception|
    render json: { error: exception.message }, status: :not_found
  end

  # rubocop:disable Metrics/AbcSize
  def show
    attachment = ActiveStorage::Attachment.find(params[:id])
    authorize!(:read, attachment.record.stream)

    fresh_when(last_modified: attachment.blob.created_at, public: true, etag: attachment.blob.checksum)
    set_content_headers_from(attachment.blob)

    if request.headers['Range'].present?
      stream_range(attachment.blob)
    else
      stream(attachment.blob)
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  # rubocop:disable Naming/AccessorMethodName
  def set_content_headers_from(blob)
    response.headers['Content-Type'] = blob.content_type
    response.headers['Content-Disposition'] = 'attachment'
    response.headers['Accept-Ranges'] = 'bytes'
  end
  # rubocop:enable Naming/AccessorMethodName

  def set_content_range_header(range, size)
    # TODO: this header is only compliant on single ranges
    response.headers['Content-Range'] = "bytes #{range.first}-#{range.end}/#{size}"
  end

  ##
  # Stream a file for download
  def stream(blob)
    blob.download do |chunk|
      response.stream.write chunk
    end
  ensure
    response.stream.close
  end

  def header_ranges(byte_size)
    Rack::Utils.get_byte_ranges(request.headers['Range'], byte_size)
  end

  ##
  # Stream a range request for download
  # rubocop:disable Metrics/AbcSize
  def stream_range(blob, chunksize: 5.megabytes)
    ranges = header_ranges(blob.byte_size)
    set_content_range_header(ranges.first, blob.byte_size)
    ranges.each do |range|
      range.step(chunksize) do |start|
        chunk_end = [start + chunksize - 1, range.end].min
        response.stream.write blob.service.download_chunk blob.key, start..chunk_end
      end
    end
  ensure
    response.stream.close
  end
  # rubocop:enable Metrics/AbcSize
end
