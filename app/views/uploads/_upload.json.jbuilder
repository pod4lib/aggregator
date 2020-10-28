json.extract! upload, :id, :name, :files, :created_at, :updated_at
json.url upload_url(upload, format: :json)
