# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe TokenAbility do
  subject { described_class.new(token) }

  let(:token) { nil }

  describe 'with a token' do
    let(:org_one) { create(:organization) }
    let(:org_two) { create(:organization) }
    let(:default_stream) { create(:stream, :default) }
    let(:token) { { 'jti' => 'anything' } }
    let(:token_attributes) { {} }

    before do
      AllowlistedJwt.create(resource: org_one, jti: 'anything', **token_attributes)
    end

    it { is_expected.to be_able_to(:read, org_one) }
    it { is_expected.to be_able_to(:read, org_two) }

    it { is_expected.to be_able_to(:create, Upload.new(organization: org_one)) }
    it { is_expected.not_to be_able_to(:create, Upload.new(organization: org_two)) }

    context 'with a token scoped to reads' do
      let(:token_attributes) { { scope: 'download' } }

      it { is_expected.to be_able_to(:read, org_one) }
      it { is_expected.to be_able_to(:read, org_two) }
      it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: org_one)) }
      it { is_expected.to be_able_to(:read, create(:upload, :binary_marc, organization: org_two)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: org_one)) }
    end

    context 'with a token scoped to upload' do
      let(:token_attributes) { { scope: 'upload' } }

      it { is_expected.to be_able_to(:read, org_one) }
      it { is_expected.not_to be_able_to(:read, org_two) }
      it { is_expected.to be_able_to(:create, Upload.new(organization: org_one)) }
    end
  end
end
