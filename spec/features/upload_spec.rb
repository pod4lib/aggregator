# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploading files to POD', type: :feature do
  context 'with an organization user' do
    let(:organization) { create(:organization, name: 'Best University') }
    let(:user) { create(:user) }

    before do
      user.add_role :member, organization
      login_as(user, scope: :user)
    end

    it 'allows the user to create a new stream and upload files' do
      visit '/'

      click_on 'Best University'
      click_on 'Create'
      click_on 'Create Stream'
      click_on 'Upload file'
      attach_file('Upload file', Rails.root.join('spec/fixtures/stanford-50.mrc.gz'))
      click_on 'Create Upload'

      expect(page).to have_content 'stanford-50.mrc.gz'
      expect(page).to have_content '17.8 KB application/gzip'
    end
  end
end
