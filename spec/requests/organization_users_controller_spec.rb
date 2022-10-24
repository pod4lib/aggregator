# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organizations/1/organization_users' do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  before do
    sign_in create(:admin)
  end

  describe 'DELETE /destroy' do
    before do
      user.add_role :member, organization
    end

    it 'removes the user from organization' do
      delete organization_user_url(organization, user)

      expect(user).not_to have_role :member, organization
    end
  end
end
