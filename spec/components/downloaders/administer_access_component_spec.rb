# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AdministerAccessComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization)).to_html)
  end

  let(:organization) { create(:organization) }
  let(:other_organizations) { [] }
  let(:user) { create(:admin) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(user))
    # rubocop:enable RSpec/AnyInstance
    Group.create!(name: 'Group A')
  end

  it 'renders the administer access controls' do # rubocop:disable RSpec/MultipleExpectations
    expect(rendered).to have_css('h4', text: 'Access settings')
    expect(rendered).to have_css('h5', text: 'Group access')
    expect(rendered).to have_css('.form-check-input', count: 1)
  end

  context 'when the user is not an admin' do
    let(:user) { create(:user) }

    it 'only renders a status icon and not a checkbox' do
      expect(rendered).to have_no_css('.form-check-input')
      expect(rendered).to have_css('i', class: 'bi bi-dash cannot_access')
    end
  end
end
