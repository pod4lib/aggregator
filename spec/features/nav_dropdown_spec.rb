# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Using the dropdown menu in the navbar', type: :feature do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:user) { create(:user) }

  before do
    user.add_role :member, organization
    user.add_role :admin
    login_as(user, scope: :user)
    visit '/'
  end

  describe 'Dropdown menu links' do
    it 'Shows affiliated organization links' do
      expect(page).to have_link 'Best University POD'
    end

    it 'Shows the manage users link' do
      expect(page).to have_link 'Manage users'
    end

    it 'Shows the edit profile link' do
      expect(page).to have_link 'Edit profile'
    end

    it 'Shows the logout link' do
      expect(page).to have_link 'Logout'
    end
  end
end
