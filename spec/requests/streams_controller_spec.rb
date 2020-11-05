# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organization/:id/stream', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { FactoryBot.create(:organization) }
  let(:stream) { FactoryBot.create(:stream, organization: organization) }

  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get resourcelist_organization_stream_path(organization_id: stream.organization.id, id: stream.id)
      expect(response).to be_successful
    end

    it 'has some resourceSync stuff in it' do
      get resourcelist_organization_stream_path(organization_id: stream.organization.id, id: stream.id)
      expect(response.body).to include '<rs:md capability="resourcelist"'
    end
  end

  describe 'POST /make_default' do
    let!(:default_stream) { organization.default_stream }

    it 'toggles on the default attribute for the new stream' do
      post make_default_organization_streams_url(organization_id: stream.organization.id, stream: stream, format: :html)
      expect(response).to redirect_to(organization_url(stream.organization))
      expect(stream.reload).to have_attributes default: true
    end

    it 'toggles off the default stream for the previous default' do
      post make_default_organization_streams_url(organization_id: stream.organization.id, stream: stream, format: :html)
      expect(default_stream.reload).to have_attributes default: false
    end
  end

  describe 'DELETE /destroy' do
    before { stream } # Ensure the stream is created before destroying

    it 'destroys the requested stream' do
      expect do
        delete organization_stream_url(organization, stream)
      end.to change(Stream, :count).by(-1)
    end

    it 'redirects to the organizations list' do
      delete organization_stream_url(organization, stream)
      expect(response).to redirect_to(organization_streams_url(organization))
    end
  end
end
