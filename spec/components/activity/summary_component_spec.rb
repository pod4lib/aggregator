# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity::SummaryComponent, type: :component do
  subject(:rendered) { Capybara::Node::Simple.new(render_inline(described_class.new).to_html) }

  let(:user) { create(:user) }

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(user))
  end
  # rubocop:enable RSpec/AnyInstance

  # rubocop:disable RSpec/MultipleExpectations
  it 'renders the summary tabs' do
    expect(rendered).to have_css('ul#summary-tabs > li', count: 2)
    expect(rendered).to have_css('div#summary-tabs-content > div#uploads-pane')
    expect(rendered).to have_css('div#summary-tabs-content > div#normalized-data-pane')
  end
  # rubocop:enable RSpec/MultipleExpectations

  context 'with an admin user' do
    let(:user) { create(:admin) }

    it 'shows the users tab' do
      expect(rendered).to have_css('ul#summary-tabs > li', count: 3)
      expect(rendered).to have_css('div#summary-tabs-content > div#users-pane')
    end
  end
end
