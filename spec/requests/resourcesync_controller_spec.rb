# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/.well-known/resourcesync', type: :request do
  before do
    sign_in FactoryBot.create(:user)
  end

  describe 'GET /index' do
    it 'has some resourceSync stuff in it' do
      get resourcesync_source_description_url
      expect(response.body).to include '<rs:md capability="description"'
    end
  end

  describe 'GET /capabilitylist' do
    it 'has some resourceSync stuff in it' do
      get resourcesync_capabilitylist_url
      expect(response.body).to include '<rs:md capability="capabilitylist"'
    end
  end
end
