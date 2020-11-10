# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
  'xmlns:rs' => 'http://www.openarchives.org/rs/terms/'
) do
  xml.tag!('rs:ln', rel: 'up', href: resourcesync_source_description_url)
  xml.tag!('rs:md', capability: 'capabilitylist')

  xml.url do
    xml.loc normalized_resourcelist_organizations_url(flavor: params[:flavor])
    xml.tag!('rs:md', capability: 'resourcelist')
  end
end
