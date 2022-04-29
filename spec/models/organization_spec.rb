# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization do
  let(:organization) { create(:organization) }

  describe '#jwt_token' do
    context 'when a jwt already exists' do
      before do
        AllowlistedJwt.create(resource: organization, jti: 'anything')
      end

      it 'does not create a new token' do
        expect do
          organization.jwt_token
        end.not_to change(AllowlistedJwt, :count)
      end

      it 'returns the appropriate token' do
        token = JWT.decode(organization.jwt_token, Settings.jwt.secret, Settings.jwt.algorithm)
        expect(token[0]['jti']).to eq AllowlistedJwt.last.jti
      end
    end

    context 'when a jwt does not exist' do
      it 'creates a new one' do
        expect do
          organization.jwt_token
        end.to change(AllowlistedJwt, :count).by(1)
      end

      it 'returns the appropriate token' do
        token = JWT.decode(organization.jwt_token, Settings.jwt.secret, Settings.jwt.algorithm)
        expect(token[0]['jti']).to eq AllowlistedJwt.last.jti
      end
    end
  end

  describe '#normalization_steps' do
    it 'defaults to a hash' do
      expect(organization.normalization_steps).to eq({})
    end
  end

  describe '#provider' do
    it 'defaults to true' do
      expect(organization.provider?).to be true
    end
  end

  describe '#providers' do
    it 'includes providers in scope' do
      org = described_class.create!(provider: true)
      expect(described_class.providers).to include(org)
    end

    it 'excludes non-providers in scope' do
      org = described_class.create!(provider: false)
      expect(described_class.providers).not_to include(org)
    end
  end
end
