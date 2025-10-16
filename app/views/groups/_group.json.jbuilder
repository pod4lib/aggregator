# frozen_string_literal: true

json.extract! group, :id, :name, :short_name, :slug, :description, :created_at, :updated_at
json.url group_url(group, format: :json)
json.organizations group.organizations do |organization|
  json.extract! organization, :id, :name, :slug, :created_at, :updated_at
  json.url organization_url(organization, format: :json)
end
