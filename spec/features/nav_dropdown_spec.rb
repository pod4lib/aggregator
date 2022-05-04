# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Using the dropdown menu in the navbar', type: :feature do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:user) { create(:user) }

  describe 'Menu links for admin user' do
    before do
      user.add_role :member, organization
      user.add_role :admin
      login_as(user, scope: :user)
      visit '/'
    end

    it 'Shows affiliated organization manage link' do
      expect(page).to have_link 'Manage Best University'
    end

    it 'Shows affiliated organization home link' do
      expect(page).to have_link 'Best University home'
    end

    it 'Shows the edit profile link' do
      expect(page).to have_link 'Edit profile'
    end

    it 'Shows the logout link' do
      expect(page).to have_link 'Logout'
    end
  end

  describe 'Menu links for owner user' do
    before do
      user.add_role :owner, organization
      login_as(user, scope: :user)
      visit '/'
    end

    it 'Shows affiliated organization manage link' do
      expect(page).to have_link 'Manage Best University'
    end

    it 'Shows affiliated organization home link' do
      expect(page).to have_link 'Best University home'
    end

    it 'Shows the edit profile link' do
      expect(page).to have_link 'Edit profile'
    end

    it 'Shows the logout link' do
      expect(page).to have_link 'Logout'
    end
  end

  describe 'Menu links for member user' do
    before do
      user.add_role :member, organization
      login_as(user, scope: :user)
      visit '/'
    end

    it 'Does not show affiliated organization manage link' do
      expect(page).not_to have_link 'Manage Best University'
    end

    it 'Shows affiliated organization home link' do
      expect(page).to have_link 'Best University home'
    end

    it 'Shows the edit profile link' do
      expect(page).to have_link 'Edit profile'
    end

    it 'Shows the logout link' do
      expect(page).to have_link 'Logout'
    end
  end
end
