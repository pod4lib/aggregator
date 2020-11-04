# frozen_string_literal: true

json.extract! upload, :id, :name, :files, :created_at, :updated_at
json.url organization_upload_url(upload.organization, upload, format: :json)
