# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

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

  describe '#slug=' do
    it 'converts empty values to nil, so friendly_id can do its thing' do
      organization.update(name: 'some org title', slug: '')

      expect(organization.slug).to eq 'some-org-title'
    end
  end

  describe '#downloader_organizations' do
    before do
      Downloader.create!(resource: other_organization, organization: organization)
    end

    it 'returns organizations that are allowed to download from this organization' do
      expect(organization.downloader_organizations).to include(other_organization)
    end
  end

  describe '#downloader_groups' do
    let(:group) { create(:group) }

    before do
      Downloader.create!(resource: group, organization: organization)
    end

    it 'returns groups that are allowed to download from this organization' do
      expect(organization.downloader_groups).to include(group)
    end
  end

  describe '#downloadable_organizations' do
    before do
      Downloader.create!(resource: organization, organization: other_organization)
    end

    it 'returns organizations that members of this group are allowed to download from' do
      expect(organization.downloadable_organizations).to include(other_organization)
    end
  end
end
