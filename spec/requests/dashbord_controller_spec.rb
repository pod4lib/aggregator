# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dashboard', type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization, default: true) }
  let(:uploads) do
    [
      create(:upload, :multiple_files, stream: stream)
    ]
  end

  before do
    sign_in create(:admin)
  end

  describe 'GET /uploads' do
    let(:recent_uploads_by_provider) do
      {
        organization => uploads
      }
    end

    it 'renders a successful response' do
      get activity_path
      expect(response).to be_successful
    end
  end
end
