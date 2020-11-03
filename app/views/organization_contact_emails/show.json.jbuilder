# frozen_string_literal: true

json.extract! @contact_email, :id, :email, :created_at, :updated_at
json.url organization_contact_emails_url(@organization, @contact_email, format: :json)
