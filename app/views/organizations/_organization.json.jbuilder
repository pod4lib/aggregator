# frozen_string_literal: true

json.extract! organization, :id, :name, :slug, :groups, :created_at, :updated_at
json.url organization_url(organization, format: :json)
json.streams organization.streams.accessible_by(current_ability) do |stream|
  json.id stream.id
  json.name stream.name
  json.default stream.default?
  json.url organization_stream_url(organization, stream, format: :json)
end
