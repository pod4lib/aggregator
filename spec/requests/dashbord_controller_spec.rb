# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/dashboard', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { FactoryBot.create(:organization) }
  let(:stream) { FactoryBot.create(:stream, organization: organization) }

  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET /uploads' do
    before do
      FactoryBot.create(:upload, :binary_marc, stream: stream)
      FactoryBot.create(:upload, :binary_marc, stream: stream)
      FactoryBot.create(:upload, :binary_marc, stream: stream)
    end

    it 'renders a successful response' do
      get activity_path
      expect(response).to be_successful
    end
  end
end
