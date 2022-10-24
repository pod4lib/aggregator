# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'editing your user profile' do
  context 'with a user' do
    let(:user) { create(:user, email: 'test@stanford.edu') }

    before do
      login_as(user, scope: :user)
    end

    it 'requires current password to change password' do
      visit '/users/edit'
      fill_in 'user_password', with: '123'
      click_on 'Change password'
      expect(page).to have_content "Current password can't be blank"
    end

    it 'allows non-password changes without passwords' do
      visit '/users/edit'
      fill_in 'user_name', with: 'Nice Name'
      click_on 'Update'
      # successful update redirects to root page
      expect(page).to have_content 'Your account has been updated successfully'
    end
  end
end
