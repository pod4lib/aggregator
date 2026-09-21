# frozen_string_literal: true

##
# Background job to harvest a resource sync resourcelist into a stream
class HarvestResourceListToStreamJob < ApplicationJob
  RS_MD_HASH_KEY = 'rs_md_hash'
  XMLNS = { sitemap: 'http://www.sitemaps.org/schemas/sitemap/0.9', rs: 'http://www.openarchives.org/rs/terms/' }.freeze

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
  def perform(stream, url:, access_token: Settings.resource_sync_harvest_token)
    http_client = access_token.present? ? HTTP.auth("Bearer #{access_token}") : HTTP

    Rails.logger.info("HarvestResourceListToStreamJob: Fetching resource list from #{url}")
    response = http_client.get(url)
    raise "Failed to fetch resource list from #{url}: #{response.status}" unless response.status.success?

    existing_files_hash = checksums_for_stream_files(stream)

    resource_list = Nokogiri::XML(response.body.to_s)
    resource_list.xpath('//sitemap:url', **XMLNS).each do |url|
      loc = url.at_xpath('sitemap:loc', **XMLNS)&.text
      hash = url.at_xpath('rs:md/@hash', **XMLNS)&.text
      next if loc.blank? || existing_files_hash.include?(hash)

      Rails.logger.info("HarvestResourceListToStreamJob: Fetching resource from #{loc}")
      resource = http_client.get(loc)
      tmpfile = create_tmpfile_for_http_response(resource.body)

      test_checksum(tmpfile, hash)

      upload = stream.uploads.build
      upload.files.attach(io: tmpfile,
                          filename: File.basename(URI.parse(loc)),
                          content_type: resource.headers['Content-Type'],
                          metadata: { RS_MD_HASH_KEY => hash })

      UploadCreatorService.call(upload)

      sleep 1
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
  end

  def checksums_for_stream_files(stream)
    stream.uploads.with_attached_files.flat_map do |u|
      u.files.map do |file|
        ["md5:#{Base64.decode64(file.blob.checksum).unpack1('H*')}", file.blob.metadata[RS_MD_HASH_KEY]]
      end
    end.to_set
  end

  def create_tmpfile_for_http_response(body)
    tmpfile = Tempfile.new binmode: true

    body.each do |chunk|
      tmpfile.write(chunk)
    end
    tmpfile.rewind
    tmpfile
  end

  def test_checksum(file, expected_checksum)
    return if expected_checksum.blank?

    algorithm, expected_hash = expected_checksum.split(':', 2)
    actual_hash = case algorithm
                  when 'md5'
                    Digest::MD5.file(file.path).hexdigest
                  when 'sha1'
                    Digest::SHA1.file(file.path).hexdigest
                  when 'sha256'
                    Digest::SHA256.file(file.path).hexdigest
                  else
                    Rails.logger.warn "Unsupported checksum algorithm: #{algorithm}"
                    return
                  end

    return if actual_hash == expected_hash

    raise "Checksum mismatch: expected #{expected_checksum}, got #{algorithm}:#{actual_hash}"
  end
end
