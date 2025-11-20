# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'downloaders', :js do
  let(:organization) { create(:organization, name: 'My Org', slug: 'my-org') }

  let(:admin) { create(:admin) }

  before do
    create(:organization, name: 'Downloader Org', slug: 'downloader-org')
    login_as(admin)
    visit organization_downloaders_path(organization)
  end

  it 'displays an alert about the current access settings' do
    expect(page).to have_link('Grant access')
    expect(page).to have_content 'My Org has restrictions set and has not granted access to any organizations or groups.'
  end

  context 'when adding a downloader' do
    it 'updates the displayed access settings after adding a downloader' do
      page.accept_alert "Allow Downloader Org to download My Org's records?" do
        click_on 'Grant access'
      end

      expect(page).to have_link('Revoke access')
      expect(page).to have_content 'My Org has restrictions set, allowing access to specific organizations.'
    end
  end
end
