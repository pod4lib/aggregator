# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject { described_class.new(user) }

  let(:user) { nil }

  describe 'for an anonymous user' do
    it { is_expected.to be_able_to(:confirm, ContactEmail) }
  end

  describe 'with a user' do
    let(:organization) { create(:organization) }
    let(:not_my_org) { create(:organization) }
    let(:default_stream) { create(:stream, :default, organization: organization) }
    let(:previous_default_stream) { create(:stream, status: 'previous-default', organization: organization) }

    context 'with an admin' do
      let(:user) { create(:admin) }

      it { is_expected.to be_able_to(:manage, :all) }
      it { is_expected.not_to be_able_to(:destroy, default_stream) }
      it { is_expected.to be_able_to(:destroy, previous_default_stream) }
    end

    context 'when a user without any roles' do
      let(:user) { User.new }

      it { is_expected.to be_able_to(:read, create(:organization)) }
      it { is_expected.not_to be_able_to(:read, Upload.new) }
      it { is_expected.not_to be_able_to(:read, Stream.new) }
      it { is_expected.not_to be_able_to(:read, AllowlistedJwt.new) }
      it { is_expected.not_to be_able_to(:destroy, default_stream) }
    end

    context 'with an owner of an org' do
      let(:user) { create(:user) }

      before do
        user.add_role :owner, organization
      end

      it { is_expected.not_to be_able_to(:destroy, default_stream) }
      it { is_expected.not_to be_able_to(:destroy, previous_default_stream) }

      # Owner organization
      it { is_expected.to be_able_to(:manage, organization) }
      it { is_expected.not_to be_able_to(:destroy, organization) }

      it { is_expected.to be_able_to(:users, organization) }
      it { is_expected.to be_able_to(:organization_details, organization) }
      it { is_expected.to be_able_to(:provider_details, organization) }

      it { is_expected.to be_able_to(:crud, Upload.new(organization: organization)) }
      it { is_expected.to be_able_to(:info, Upload.new(organization: organization)) }

      it { is_expected.to be_able_to(:crud, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:normalized_data, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:processing_status, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:profile, Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: organization)) }

      it { is_expected.to be_able_to(:crud, AllowlistedJwt.new(resource: organization)) }

      # Non-member organization
      it { is_expected.not_to be_able_to(:manage, not_my_org) }
      it { is_expected.to be_able_to(:read, not_my_org) }
      it { is_expected.to be_able_to(:users, not_my_org) }
      it { is_expected.to be_able_to(:organization_details, not_my_org) }
      it { is_expected.to be_able_to(:provider_details, not_my_org) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:info, Upload.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: not_my_org)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:normalized_data, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:processing_status, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:profile, Stream.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: not_my_org)) }

      it { is_expected.not_to be_able_to(:crud, AllowlistedJwt.new(resource: not_my_org)) }
    end

    context 'with a member of an org' do
      let(:user) { create(:user) }

      before do
        user.add_role :member, organization
      end

      it { is_expected.not_to be_able_to(:destroy, default_stream) }

      # Member organization
      it { is_expected.not_to be_able_to(:manage, organization) }
      it { is_expected.to be_able_to(:read, organization) }
      it { is_expected.to be_able_to(:users, organization) }
      it { is_expected.to be_able_to(:organization_details, organization) }
      it { is_expected.to be_able_to(:provider_details, organization) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: organization)) }
      it { is_expected.to be_able_to(:info, Upload.new(organization: organization)) }
      it { is_expected.to be_able_to(:create, Upload.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: organization)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:normalized_data, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:processing_status, Stream.new(organization: organization)) }
      it { is_expected.to be_able_to(:profile, Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: organization)) }

      it { is_expected.to be_able_to(:read, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:create, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:update, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:destroy, AllowlistedJwt.new(resource: organization)) }

      # Non-member organization
      it { is_expected.not_to be_able_to(:manage, not_my_org) }
      it { is_expected.to be_able_to(:read, not_my_org) }
      it { is_expected.to be_able_to(:users, not_my_org) }
      it { is_expected.to be_able_to(:organization_details, not_my_org) }
      it { is_expected.to be_able_to(:provider_details, not_my_org) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:info, Upload.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: not_my_org)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:normalized_data, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:processing_status, Stream.new(organization: not_my_org)) }
      it { is_expected.to be_able_to(:profile, Stream.new(organization: not_my_org)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: not_my_org)) }

      it { is_expected.not_to be_able_to(:crud, AllowlistedJwt.new(resource: not_my_org)) }
    end
  end
end
