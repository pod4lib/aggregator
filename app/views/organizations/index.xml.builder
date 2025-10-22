# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.sitemapindex(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
  'xmlns:rs' => 'http://www.openarchives.org/rs/terms/'
) do
  href = if params[:normalized]
           resourcesync_normalized_dump_capabilitylist_url(flavor: params[:flavor])
         else
           resourcesync_capabilitylist_url
         end

  xml.tag!('rs:ln', rel: 'up', href: href)
  xml.tag!('rs:md', capability: 'resourcelist', at: Time.zone.now.iso8601)
  @organizations.each do |org|
    next unless can? :read, org.default_stream

    xml.sitemap do
      xml.tag!(
        'rs:md',
        at: if params[:normalized]
              (
                org.default_stream.delta_dumps.maximum(:updated_at) ||
                org.default_stream.full_dumps.maximum(:updated_at) ||
                org.default_stream.updated_at
              ).iso8601
            else
              org.default_stream.updated_at.iso8601
            end
      )
      xml.loc(if params[:normalized]
                normalized_resourcelist_organization_stream_url(org, org.default_stream, flavor: params[:flavor])
              else
                resourcelist_organization_stream_url(org, org.default_stream)
              end)
    end
  end
end
