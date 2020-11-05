# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
  'xmlns:rs' => 'http://www.openarchives.org/rs/terms/'
) do
  xml.tag!('rs:ln', rel: 'up', href: resourcelist_organizations_url)
  xml.tag!('rs:md', capability: 'resourcelist', at: @stream.updated_at.iso8601)
  xml.url(removed_since_previous_stream_organization_stream_url(@stream))
  @stream.files.each do |file|
    xml.url do
      xml.tag!(
        'rs:md',
        hash: "md5:#{Base64.decode64(file.checksum).unpack1('H*')}",
        type: file.content_type,
        length: file.byte_size
      )
      xml.loc(download_url(file))
      xml.lastmod(file.created_at)
    end
  end
end
