# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AccessSummaryTableRowComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization, other_org: other_org)).to_html)
  end

  let(:organization) { create(:organization, name: 'Test Org') }
  let(:other_org) { create(:organization, name: 'Other Org') }

  it 'renders a table row with organization names and access information' do # rubocop:disable RSpec/MultipleExpectations
    expect(rendered).to have_css('a', text: 'Other Org')
    expect(rendered).to have_css('i', class: 'cannot_access')
    expect(rendered.text).to include('No access granted to Other Org')
  end
end
