# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AdministerAccessComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization, groups: groups,
                                                                 other_organizations: other_organizations)).to_html)
  end

  let(:organization) { create(:organization) }
  let(:groups) { create_list(:group, 2) }
  let(:other_organizations) { [] }
  let(:admin_user) { create(:admin) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(admin_user))
    # rubocop:enable RSpec/AnyInstance
  end

  it 'renders the administer access controls' do # rubocop:disable RSpec/MultipleExpectations
    expect(rendered).to have_css('h4', text: 'Access settings')
    expect(rendered).to have_css('h5', text: 'Group access')
    expect(rendered).to have_css('.form-check-input', count: 2)
  end
end
