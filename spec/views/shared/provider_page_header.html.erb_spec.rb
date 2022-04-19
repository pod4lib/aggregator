# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_provider_page_header', type: :view do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:admin) { create(:admin) }

  before do
    assign(:organization, organization)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'displays the tab links for all users' do
    render

    expect(rendered).to have_link('Uploaded files')
    expect(rendered).to have_link('Normalized data')
    expect(rendered).to have_link('MARC analysis')
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'displays the Processing status link for priveleged users' do
    allow(view).to receive(:can?).and_return(true)
    render

    expect(rendered).to have_link('Processing status')
  end
end
