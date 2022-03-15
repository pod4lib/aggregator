# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:org1) { create(:organization) }
  let(:org2) { create(:organization) }

  describe '#organizations' do
    context 'when user is an org owner' do
      before do
        user.add_role :owner, org1
      end

      it 'returns owned orgs' do
        expect(user.organizations).to match_array([org1])
      end
    end

    context 'when user is an org member' do
      before do
        user.add_role :member, org2
      end

      it 'returns member orgs' do
        expect(user.organizations).to match_array([org2])
      end
    end

    context 'when filtering for specific org roles' do
      before do
        user.add_role :owner, org1
        user.add_role :member, org2
      end

      it 'returns only specified orgs' do
        expect(user.organizations(:owner)).to match_array([org1])
      end
    end
  end
end
