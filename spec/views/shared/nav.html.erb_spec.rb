# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_nav', type: :view do
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

    it 'displays the edit profile link' do
      render

      expect(rendered).to have_link('Edit profile')
    end
  end
end
