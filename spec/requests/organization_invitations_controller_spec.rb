# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organizations/1/invite', type: :request do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get organization_invite_new_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:user) { FactoryBot.build(:user) }
    let(:valid_attributes) do
      { email: user.email }
    end

    it 'invites the user' do
      expect do
        post organization_invite_url(organization), params: { user: valid_attributes }
      end.to change(User, :count).by(1)
    end

    it 'adds the user to the organization' do
      post organization_invite_url(organization), params: { user: valid_attributes }

      expect(User.find_by(email: valid_attributes[:email])).to have_role :member, organization
    end

    context 'with a user that already exists' do
      let(:user) { FactoryBot.create(:user) }

      it 'adds the user to the organization' do
        post organization_invite_url(organization), params: { user: valid_attributes }

        expect(user).to have_role :member, organization
      end
    end

    it 'redirects back to the organization' do
      post organization_invite_url(organization), params: { user: valid_attributes }
      expect(response).to redirect_to(organization_url(organization))
    end
  end
end
