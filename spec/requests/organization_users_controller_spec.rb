# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/organizations/1/organization_users', type: :request do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in FactoryBot.create(:admin)
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
