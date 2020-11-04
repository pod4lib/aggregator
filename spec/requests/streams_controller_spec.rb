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
      get organization_stream_path(organization_id: stream.organization.id, id: stream.id)
      expect(response).to be_successful
    end

    it 'has some resourceSync stuff in it' do
      get organization_stream_path(organization_id: stream.organization.id, id: stream.id)
      expect(response.body).to include '<rs:md capability="resourceList"'
    end
  end
end
