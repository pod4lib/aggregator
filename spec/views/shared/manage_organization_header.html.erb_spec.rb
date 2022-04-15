# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_manage_organization_header', type: :view do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:admin) { create(:admin) }

  before do
    assign(:organization, organization)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'displays the tab links for all users' do
    render

    expect(rendered).to have_link('Users')
    expect(rendered).to have_link('Access tokens')
    expect(rendered).to have_link('Organization details')
    expect(rendered).to have_link('Provider details')
  end
  # rubocop:enable RSpec/MultipleExpectations
end
