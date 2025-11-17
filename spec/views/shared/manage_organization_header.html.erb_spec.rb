# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_manage_organization_header' do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:admin) { create(:admin) }

  before do
    assign(:organization, organization)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'displays the tab links for all users' do
    render

    expect(rendered).to have_link('Users')
    expect(rendered).to have_link('Organization details')
    expect(rendered).to have_link('Provider details')
  end
  # rubocop:enable RSpec/MultipleExpectations

  context 'when user has priveleges' do
    before do
      allow(view).to receive(:can?).and_return(true)
      render
    end

    it 'displays the Access tokens link' do
      expect(rendered).to have_link('Access tokens')
    end

    it 'displays the access restrictions link' do
      expect(rendered).to have_link('Access restrictions')
    end
  end
end
