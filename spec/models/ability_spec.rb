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
    let(:unrestricted_other_org) { create(:organization, :unrestricted) }
    let(:restricted_other_org) { create(:organization) }
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
      it { is_expected.to be_able_to(:read, Downloader.new) }
      it { is_expected.to be_able_to(:read, Group.new) }
      it { is_expected.not_to be_able_to(:read, Upload.new) }
      it { is_expected.not_to be_able_to(:read, Stream.new) }
      it { is_expected.not_to be_able_to(:read, AllowlistedJwt.new) }
      it { is_expected.not_to be_able_to(:destroy, default_stream) }
      it { is_expected.not_to be_able_to(:control_access, organization) }
    end

    context 'with an owner of an org' do
      let(:user) { create(:user) }

      before do
        user.add_role :member, organization # Owners are also members
        user.add_role :owner, organization
        allow(Settings).to receive(:allow_organization_owners_to_manage_access).and_return(true)
      end

      it { is_expected.not_to be_able_to(:destroy, default_stream) }
      it { is_expected.not_to be_able_to(:destroy, previous_default_stream) }

      # Owner organization
      it { is_expected.to be_able_to(%i[edit administer], organization) }
      it { is_expected.to be_able_to(:control_access, organization) }

      it { is_expected.not_to be_able_to(:destroy, organization) }

      it { is_expected.to be_able_to(%i[read create edit destroy], Upload.new(organization: organization)) }

      it { is_expected.to be_able_to(%i[read create edit destroy], Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: organization)) }

      it { is_expected.to be_able_to(%i[read create edit destroy], AllowlistedJwt.new(resource: organization)) }

      # Non-member organization (unrestricted)
      it { is_expected.not_to be_able_to(:manage, unrestricted_other_org) }
      it { is_expected.to be_able_to(:read, unrestricted_other_org) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: unrestricted_other_org)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: unrestricted_other_org)) }

      it { is_expected.not_to be_able_to(:manage, AllowlistedJwt.new(resource: unrestricted_other_org)) }

      # Non-member organization (restricted)
      it { is_expected.to be_able_to(:read, restricted_other_org) }
      it { is_expected.not_to be_able_to(:read, Upload.new(organization: restricted_other_org)) }
      it { is_expected.not_to be_able_to(:read, Stream.new(organization: restricted_other_org)) }
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
      it { is_expected.not_to be_able_to(:control_access, organization) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: organization)) }
      it { is_expected.to be_able_to(:create, Upload.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: organization)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: organization)) }
      it { is_expected.not_to be_able_to(:reanalyze, Stream.new(organization: organization)) }

      it { is_expected.to be_able_to(:read, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:create, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:update, AllowlistedJwt.new(resource: organization)) }
      it { is_expected.not_to be_able_to(:destroy, AllowlistedJwt.new(resource: organization)) }

      # Non-member organization
      it { is_expected.not_to be_able_to(:manage, unrestricted_other_org) }
      it { is_expected.to be_able_to(:read, unrestricted_other_org) }

      it { is_expected.to be_able_to(:read, Upload.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:create, Upload.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:destroy, Upload.new(organization: unrestricted_other_org)) }

      it { is_expected.to be_able_to(:read, Stream.new(organization: unrestricted_other_org)) }
      it { is_expected.not_to be_able_to(:create, Stream.new(organization: unrestricted_other_org)) }

      it { is_expected.not_to be_able_to(:manage, AllowlistedJwt.new(resource: unrestricted_other_org)) }

      # Non-member organization (restricted)
      it { is_expected.to be_able_to(:read, restricted_other_org) }
      it { is_expected.not_to be_able_to(:read, Upload.new(organization: restricted_other_org)) }
      it { is_expected.not_to be_able_to(:read, Stream.new(organization: restricted_other_org)) }
      it { is_expected.not_to be_able_to(:read, MarcRecord.new(upload: Upload.new(organization: restricted_other_org))) }
      it { is_expected.not_to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: restricted_other_org))) }
    end

    context 'when an organization is restricted but the user belongs to an organization granted access' do
      let(:user) { create(:user) }

      before do
        user.add_role :member, organization
        Downloader.create!(organization: restricted_other_org, resource: organization)
      end

      it { is_expected.to be_able_to(:read, Upload.new(organization: restricted_other_org)) }
      it { is_expected.to be_able_to(:read, Stream.new(organization: restricted_other_org)) }
      it { is_expected.to be_able_to(:read, MarcRecord.new(upload: Upload.new(organization: restricted_other_org))) }
      it { is_expected.to be_able_to(:read, ActiveStorage::Attachment.new(record: Upload.new(organization: restricted_other_org))) }
    end
  end
end
