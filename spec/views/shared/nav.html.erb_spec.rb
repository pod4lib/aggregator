# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_nav' do
  before do
    allow(view).to receive(:current_user).and_return(current_user)
  end

  context 'when not logged in' do
    let(:current_user) { nil }

    it 'displays the login link' do
      render

      expect(rendered).to have_link('Login')
    end
  end

  context 'when logged in' do
    let(:current_user) { create(:user) }

    it 'displays the logout link' do
      render

      expect(rendered).to have_link('Logout')
    end
  end

  context 'when user has multiple roles' do
    let(:current_user) { create(:user) }
    let(:organization) { create(:organization) }

    it 'displays the organization only once' do
      current_user.add_role :member, organization
      current_user.add_role :owner, organization
      render

      assert_select 'a', text: "#{organization.name} home", count: 1
    end
  end
end
