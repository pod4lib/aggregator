# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe TokenAbility do
  subject { described_class.new(token) }

  let(:token) { nil }

  describe 'with a token' do
    let(:organization) { create(:organization) }
    let(:unrestricted_other_org) { create(:organization, :unrestricted) }
    let(:restricted_other_org) { create(:organization) }
    let(:default_stream) { create(:stream, :default) }
    let(:token) { { 'jti' => 'anything' } }
    let(:token_attributes) { {} }

    before do
      AllowlistedJwt.create(resource: organization, jti: 'anything', **token_attributes)
    end

    it { is_expected.to be_able_to(:read, organization) }
    it { is_expected.to be_able_to(:read, unrestricted_other_org) }
    it { is_expected.to be_able_to(:read, restricted_other_org) }

    it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: organization)) }
    it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: unrestricted_other_org)) }
    it { is_expected.not_to be_able_to(:read, create(:upload, :binary_marc, organization: restricted_other_org)) }

    it { is_expected.to be_able_to(:read, create(:stream, organization: organization)) }
    it { is_expected.to be_able_to(:read, create(:stream, organization: unrestricted_other_org)) }
    it { is_expected.not_to be_able_to(:read, create(:stream, organization: restricted_other_org)) }

    it { is_expected.to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: organization))) }
    it { is_expected.to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: unrestricted_other_org))) }
    it { is_expected.not_to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: restricted_other_org))) }

    it { is_expected.to be_able_to(:create, Upload.new(organization: organization)) }
    it { is_expected.not_to be_able_to(:create, Upload.new(organization: unrestricted_other_org)) }

    context 'when the organization has been granted record/download access to the restricted organization' do
      before do
        Downloader.create!(organization: restricted_other_org, resource: organization)
      end

      it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: restricted_other_org)) }
      it { is_expected.to be_able_to(:read, create(:stream, organization: restricted_other_org)) }
      it { is_expected.to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: restricted_other_org))) }
    end

    context 'with a token scoped to reads' do
      let(:token_attributes) { { scope: 'download' } }

      it { is_expected.to be_able_to(:read, organization) }
      it { is_expected.to be_able_to(:read, unrestricted_other_org) }
      it { is_expected.to be_able_to(:read, restricted_other_org) }
      it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: organization)) }
      it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:read, create(:upload, :binary_marc, organization: restricted_other_org)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: organization)) }
    end

    context 'with a token scoped to upload' do
      let(:token_attributes) { { scope: 'upload' } }

      it { is_expected.to be_able_to(:read, organization) }
      it { is_expected.not_to be_able_to(:read, unrestricted_other_org) }
      it { is_expected.not_to be_able_to(:read, restricted_other_org) }
      it { is_expected.to be_able_to(:create, Upload.new(organization: organization)) }
    end
  end
end
