# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organizations/1/allowlisted_jwts' do
  let(:organization) { create(:organization) }

  before do
    sign_in create(:admin)
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      organization.allowlisted_jwts.create! jti: 'whatever'
      get organization_allowlisted_jwts_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_organization_allowlisted_jwt_url(organization)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:valid_attributes) { { label: 'best token ever', scope: 'download' } }

    context 'with valid parameters' do
      it 'creates a new AllowlistedJwt' do
        expect do
          post organization_allowlisted_jwts_url(organization)
        end.to change(AllowlistedJwt, :count).by(1)
      end

      it 'creates a new AllowlistedJwt with a label' do
        post organization_allowlisted_jwts_url(organization), params: { allowlisted_jwt: valid_attributes }
        expect(AllowlistedJwt.last).to have_attributes label: 'best token ever', scope: 'download'
      end

      it 'redirects to the list of tokens' do
        post organization_allowlisted_jwts_url(organization)
        expect(response).to redirect_to(organization_allowlisted_jwts_url(organization))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested upload' do
      allowlisted_jwt = organization.allowlisted_jwts.create! jti: 'delete_me'
      expect do
        delete organization_allowlisted_jwt_url(organization, allowlisted_jwt)
      end.to change(AllowlistedJwt, :count).by(-1)
    end

    it 'redirects to the uploads list' do
      allowlisted_jwt = organization.allowlisted_jwts.create! jti: 'delete_me'
      delete organization_allowlisted_jwt_url(organization, allowlisted_jwt)
      expect(response).to redirect_to(organization_allowlisted_jwts_url(organization))
    end
  end
end
