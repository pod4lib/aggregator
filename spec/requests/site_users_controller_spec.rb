# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/site_users', type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get site_users_url
      expect(response).to be_successful
    end
  end

  describe 'PATCH /update' do
    context 'with add parameters' do
      it 'adds the role to the user' do
        patch site_user_url(user), params: { add_role: 'whatever' }
        user.reload
        expect(user).to have_role :whatever
      end

      it 'redirects to the site users page' do
        patch site_user_url(user), params: { add_role: 'whatever' }
        expect(response).to redirect_to(site_users_url)
      end
    end

    context 'with remove parameters' do
      before do
        user.add_role :whatever
      end

      it 'adds the role to the user' do
        patch site_user_url(user), params: { remove_role: 'whatever' }
        user.reload
        expect(user).not_to have_role :whatever
      end
    end
  end
end
