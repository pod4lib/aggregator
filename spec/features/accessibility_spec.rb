# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site Accessibility', :js do
  describe 'user logged out' do
    it 'homepage is accessible' do
      visit root_path
      expect(page).to be_accessible
    end

    it 'new_user_password is accessible' do
      visit new_user_password_path
      expect(page).to be_accessible
    end
  end

  describe 'user logged in' do
    let(:user) { create(:admin) }
    let(:organization) { create(:organization, name: 'Best University') }

    before do
      user.add_role :member, organization
      login_as(user)
    end

    it 'the homepage is accessible' do
      visit root_path
      expect(page).to be_accessible
    end

    it 'the dashboard is accessible' do
      visit activity_path
      expect(page).to be_accessible
    end

    it 'the data page is accessible' do
      visit data_path
      expect(page).to be_accessible
    end

    it 'the organization_users_path is accessible' do
      visit organization_users_path(organization)
      expect(page).to be_accessible
    end

    it 'the organization_invite_new_path is accessible' do
      visit organization_invite_new_path(organization)
      expect(page).to be_accessible
    end

    it 'the organization_allowlisted_jwts_path is accessible' do
      visit organization_allowlisted_jwts_path(organization)
      expect(page).to be_accessible
    end

    it 'the organization_details_organization_path is accessible' do
      visit organization_details_organization_path(organization)
      expect(page).to be_accessible
    end

    it 'the provider_details_organization_path is accessible' do
      visit provider_details_organization_path(organization)
      expect(page).to be_accessible
    end

    it 'the new_organization_stream_path is accessible' do
      visit new_organization_stream_path(organization)
      expect(page).to be_accessible
    end

    it 'the organizations_path is accessible' do
      visit organizations_path
      expect(page).to be_accessible
    end

    it 'the new_organization_path is accessible' do
      visit new_organization_path
      expect(page).to be_accessible
    end

    it 'the site_users is accessible' do
      visit site_users_path
      expect(page).to be_accessible
    end
  end
end
