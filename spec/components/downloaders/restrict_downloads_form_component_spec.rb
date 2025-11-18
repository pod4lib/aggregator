# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Downloaders::RestrictDownloadsFormComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization)).to_html)
  end

  let(:organization) { create(:organization) }
  let(:admin_user) { create(:admin) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(admin_user))
    # rubocop:enable RSpec/AnyInstance
  end

  it 'renders the restrict downloads form' do # rubocop:disable RSpec/MultipleExpectations
    expect(rendered).to have_css('label', text: 'Restrict downloads')
    expect(rendered).to have_css('option', text: 'Unrestricted')
    expect(rendered).to have_css('option', text: 'Restricted')
  end
end
