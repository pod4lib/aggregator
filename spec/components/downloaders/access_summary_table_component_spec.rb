# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AccessSummaryTableComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization)).to_html)
  end

  let(:organization) { create(:organization, name: 'Test Org') }
  let(:user) { create(:user) }

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(user))
    Organization.create(name: 'Other Org 1')
  end
  # rubocop:enable RSpec/AnyInstance

  it 'renders a table header' do # rubocop:disable RSpec/MultipleExpectations
    expect(rendered).to have_css('th', text: 'Organization')
    expect(rendered).to have_css('th', text: 'Can access records from Test Org?')
    expect(rendered).to have_css('th', text: 'Summary of access granted by Test Org')
    expect(rendered).to have_css('th', text: 'Test Org can access records?')
    expect(rendered).to have_css('th', text: 'Summary of access granted to Test Org')
  end

  context 'with a consumer-only organization' do
    let(:organization) { create(:organization, name: 'Consumer Org', provider: false) }

    it 'does not render provider-specific columns' do # rubocop:disable RSpec/MultipleExpectations
      expect(rendered).to have_no_css('th', text: 'Can access records from Consumer Org?')
      expect(rendered).to have_no_css('th', text: 'Summary of access granted by Consumer Org')

      expect(rendered).to have_css('th', text: 'Consumer Org can access records?')
      expect(rendered).to have_css('th', text: 'Summary of access granted to Consumer Org')
    end
  end
end
