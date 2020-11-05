# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
  'xmlns:rs' => 'http://www.openarchives.org/rs/terms/'
) do
  xml.tag!('rs:md', capability: 'resourcelist', at: Time.zone.now.iso8601)
  @organizations.each do |org|
    xml.url do
      xml.tag!(
        'rs:md',
        at: org.default_stream.updated_at.iso8601
      )
      xml.loc(resourcelist_organization_stream_url(org, org.default_stream))
    end
  end
end
