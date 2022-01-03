# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dashboard', type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }

  before do
    sign_in create(:admin)
  end

  describe 'GET /uploads' do
    before do
      create(:upload, :binary_marc, stream: stream)
      create(:upload, :binary_marc, stream: stream)
      create(:upload, :binary_marc, stream: stream)
    end

    it 'renders a successful response' do
      get activity_path
      expect(response).to be_successful
    end
  end
end
