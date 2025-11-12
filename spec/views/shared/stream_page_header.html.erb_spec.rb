# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_stream_page_header' do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:stream) { create(:stream, organization: organization) }
  let(:current_user) { create(:user) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
  end

  it 'does not display uploads for users without the proper role' do
    sign_in current_user
    render

    expect(rendered).to have_no_link('Uploads')
  end

  context 'when user is an organization member' do
    before do
      current_user.add_role :member, organization
      sign_in current_user
      render
    end

    it 'displays the upload links' do
      expect(rendered).to have_link('Uploads')
      expect(rendered).to have_link('Normalized data')
    end
  end
end
